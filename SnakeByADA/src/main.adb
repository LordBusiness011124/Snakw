with Ada.Characters.Latin_1;
with Ada.Directories;
with Ada.Real_Time;
with Ada.Text_IO;
with Snake_Game;

procedure Main is
   use Ada.Real_Time;
   use Ada.Text_IO;
   use type Snake_Game.Position;

   Tick_Interval : constant Time_Span := Milliseconds (140);

   State  : Snake_Game.Game_State;
   Paused : Boolean := False;
   Quit   : Boolean := False;
   Clean_On_Exit : Boolean := False;

   Esc_Stage : Natural := 0;

   function ANSI (S : String) return String is
   begin
      return Ada.Characters.Latin_1.ESC & S;
   end ANSI;

   procedure Handle_Direction_Key (Ch : Character) is
   begin
      case Ch is
         when 'w' | 'W' => Snake_Game.Set_Direction (State, Snake_Game.Up);
         when 's' | 'S' => Snake_Game.Set_Direction (State, Snake_Game.Down);
         when 'a' | 'A' => Snake_Game.Set_Direction (State, Snake_Game.Left);
         when 'd' | 'D' => Snake_Game.Set_Direction (State, Snake_Game.Right);
         when others => null;
      end case;
   end Handle_Direction_Key;

   procedure Handle_Input (Ch : Character) is
   begin
      if Esc_Stage = 1 then
         if Ch = '[' then
            Esc_Stage := 2;
         else
            Esc_Stage := 0;
         end if;
         return;
      elsif Esc_Stage = 2 then
         case Ch is
            when 'A' => Snake_Game.Set_Direction (State, Snake_Game.Up);
            when 'B' => Snake_Game.Set_Direction (State, Snake_Game.Down);
            when 'C' => Snake_Game.Set_Direction (State, Snake_Game.Right);
            when 'D' => Snake_Game.Set_Direction (State, Snake_Game.Left);
            when others => null;
         end case;
         Esc_Stage := 0;
         return;
      end if;

      if Ch = Ada.Characters.Latin_1.ESC then
         Esc_Stage := 1;
         return;
      end if;

      case Ch is
         when 'p' | 'P' =>
            if not Snake_Game.Is_Game_Over (State) then
               Paused := not Paused;
            end if;
         when 'r' | 'R' =>
            Snake_Game.Restart (State);
            Paused := False;
         when 'q' | 'Q' =>
            Quit := True;
            Clean_On_Exit := True;
         when others =>
            Handle_Direction_Key (Ch);
      end case;
   end Handle_Input;

   procedure Delete_Matching (Pattern : String) is
      Search : Ada.Directories.Search_Type;
      Dir_Ent  : Ada.Directories.Directory_Entry_Type;
   begin
      Ada.Directories.Start_Search
        (Search    => Search,
         Directory => ".",
         Pattern   => Pattern,
         Filter    =>
           (Ada.Directories.Ordinary_File => True,
            Ada.Directories.Directory      => False,
            Ada.Directories.Special_File   => False));

      while Ada.Directories.More_Entries (Search) loop
         Ada.Directories.Get_Next_Entry (Search, Dir_Ent);
         declare
            Name : constant String := Ada.Directories.Full_Name (Dir_Ent);
         begin
            Ada.Directories.Delete_File (Name);
         exception
            when others =>
               null;
         end;
      end loop;

      Ada.Directories.End_Search (Search);
   exception
      when others =>
         null;
   end Delete_Matching;

   procedure Cleanup_Build_Artifacts is
   begin
      Delete_Matching ("*.ali");
      Delete_Matching ("*.o");
      Delete_Matching ("*.bexch");
      Delete_Matching ("*.stdout");
      Delete_Matching ("*.stderr");
      Delete_Matching ("b__*");
      Delete_Matching ("snake");
      Delete_Matching ("snake_game_tests");
   end Cleanup_Build_Artifacts;

   procedure Render is
      Head : constant Snake_Game.Position := Snake_Game.Snake_Head (State);
      F    : constant Snake_Game.Position := Snake_Game.Food (State);
   begin
      Put (ANSI ("[2J"));
      Put (ANSI ("[H"));

      Put_Line ("Snake (Ada)");
      Put_Line ("Score: " & Natural'Image (Snake_Game.Score (State)));
      Put_Line ("Controls: arrows/WASD move, P pause, R restart, Q quit");

      if Snake_Game.Is_Game_Over (State) then
         Put_Line ("GAME OVER - press R to restart or Q to quit");
      elsif Paused then
         Put_Line ("PAUSED - press P to resume");
      else
         Put_Line (" ");
      end if;

      Put ("+");
      for X in 1 .. Snake_Game.Grid_Width loop
         pragma Unreferenced (X);
         Put ("-");
      end loop;
      Put_Line ("+");

      for Y in 1 .. Snake_Game.Grid_Height loop
         Put ("|");
         for X in 1 .. Snake_Game.Grid_Width loop
            declare
               Pos : constant Snake_Game.Position := (X => X, Y => Y);
            begin
               if Pos = Head then
                  Put ("O");
               elsif Snake_Game.Is_Snake_Cell (State, Pos) then
                  Put ("o");
               elsif Pos = F then
                  Put ("*");
               else
                  Put (" ");
               end if;
            end;
         end loop;
         Put_Line ("|");
      end loop;

      Put ("+");
      for X in 1 .. Snake_Game.Grid_Width loop
         pragma Unreferenced (X);
         Put ("-");
      end loop;
      Put_Line ("+");
   end Render;

   Next_Tick : Time;

begin
   Snake_Game.Initialize (State, Seed => 7);
   Render;

   Put (ANSI ("[?25l"));

   Next_Tick := Clock + Tick_Interval;

   while not Quit loop
      while Clock < Next_Tick loop
         declare
            Ch        : Character;
            Available : Boolean;
         begin
            Get_Immediate (Ch, Available);
            if Available then
               Handle_Input (Ch);
               Render;
            else
               delay 0.01;
            end if;
         end;
      end loop;

      if not Paused and then not Snake_Game.Is_Game_Over (State) then
         Snake_Game.Tick (State);
      end if;
      Render;
      Next_Tick := Next_Tick + Tick_Interval;
   end loop;

   if Clean_On_Exit then
      Cleanup_Build_Artifacts;
   end if;

   Put (ANSI ("[?25h"));
   New_Line;
end Main;
