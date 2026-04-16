package body Snake_Game is

   function Opposite (A, B : Direction) return Boolean is
   begin
      return (A = Up and B = Down)
        or (A = Down and B = Up)
        or (A = Left and B = Right)
        or (A = Right and B = Left);
   end Opposite;

   function Next_Seed (Value : Positive) return Positive is
      Raw : constant Long_Long_Integer :=
        (Long_Long_Integer (Value) * 1_103_515_245 + 12_345)
        mod 2_147_483_647;
   begin
      if Raw = 0 then
         return 1;
      end if;
      return Positive (Raw);
   end Next_Seed;

   function Random_Range (State : in out Game_State; Max : Positive) return Positive is
   begin
      State.Seed_Value := Next_Seed (State.Seed_Value);
      return Positive ((State.Seed_Value mod Max) + 1);
   end Random_Range;

   procedure Spawn_Food (State : in out Game_State) is
      Cell_Count : constant Positive := Grid_Width * Grid_Height;
      Free_Count : Natural := 0;
      Free_Cells : Position_Array;
   begin
      for Y in 1 .. Grid_Height loop
         for X in 1 .. Grid_Width loop
            declare
               Pos : constant Position := (X => X, Y => Y);
            begin
               if not Is_Snake_Cell (State, Pos) then
                  Free_Count := Free_Count + 1;
                  Free_Cells (Free_Count) := Pos;
               end if;
            end;
         end loop;
      end loop;

      if Free_Count = 0 then
         State.Game_Over_Flag := True;
         return;
      end if;

      declare
         Index : constant Positive := Random_Range (State, Positive (Free_Count));
      begin
         State.Food_Pos := Free_Cells (Index);
      end;

      pragma Unreferenced (Cell_Count);
   end Spawn_Food;

   procedure Initialize (State : out Game_State; Seed : Positive := 1) is
      Mid_X : constant Positive := (Grid_Width / 2);
      Mid_Y : constant Positive := (Grid_Height / 2);
   begin
      State.Length := 3;
      State.Current_Dir := Right;
      State.Pending_Dir := Right;
      State.Score_Value := 0;
      State.Game_Over_Flag := False;
      State.Seed_Value := Seed;

      State.Snake (1) := (X => Mid_X, Y => Mid_Y);
      State.Snake (2) := (X => Mid_X - 1, Y => Mid_Y);
      State.Snake (3) := (X => Mid_X - 2, Y => Mid_Y);

      Spawn_Food (State);
   end Initialize;

   procedure Restart (State : in out Game_State) is
      Existing_Seed : constant Positive := State.Seed_Value;
   begin
      Initialize (State, Existing_Seed);
   end Restart;

   procedure Set_Direction (State : in out Game_State; Dir : Direction) is
   begin
      if not Opposite (State.Current_Dir, Dir) then
         State.Pending_Dir := Dir;
      end if;
   end Set_Direction;

   procedure Set_Food (State : in out Game_State; Pos : Position) is
   begin
      if not Is_Snake_Cell (State, Pos) then
         State.Food_Pos := Pos;
      end if;
   end Set_Food;

   procedure Tick (State : in out Game_State) is
      Head     : constant Position := State.Snake (1);
      New_Head : Position := Head;
      Grow     : Boolean;
      Check_To : Positive;
   begin
      if State.Game_Over_Flag then
         return;
      end if;

      State.Current_Dir := State.Pending_Dir;

      case State.Current_Dir is
         when Up =>
            if Head.Y = 1 then
               State.Game_Over_Flag := True;
               return;
            end if;
            New_Head.Y := Head.Y - 1;
         when Down =>
            if Head.Y = Grid_Height then
               State.Game_Over_Flag := True;
               return;
            end if;
            New_Head.Y := Head.Y + 1;
         when Left =>
            if Head.X = 1 then
               State.Game_Over_Flag := True;
               return;
            end if;
            New_Head.X := Head.X - 1;
         when Right =>
            if Head.X = Grid_Width then
               State.Game_Over_Flag := True;
               return;
            end if;
            New_Head.X := Head.X + 1;
      end case;

      Grow := New_Head = State.Food_Pos;

      if Grow then
         Check_To := State.Length;
      else
         Check_To := Positive'Max (1, State.Length - 1);
      end if;

      for I in 1 .. Check_To loop
         if State.Snake (I) = New_Head then
            State.Game_Over_Flag := True;
            return;
         end if;
      end loop;

      if Grow then
         if State.Length < Max_Length then
            for I in reverse 1 .. State.Length loop
               State.Snake (I + 1) := State.Snake (I);
            end loop;
            State.Length := State.Length + 1;
            State.Snake (1) := New_Head;
            State.Score_Value := State.Score_Value + 1;
            Spawn_Food (State);
         else
            State.Game_Over_Flag := True;
         end if;
      else
         for I in reverse 1 .. State.Length - 1 loop
            State.Snake (I + 1) := State.Snake (I);
         end loop;
         State.Snake (1) := New_Head;
      end if;
   end Tick;

   function Snake_Head (State : Game_State) return Position is
   begin
      return State.Snake (1);
   end Snake_Head;

   function Snake_Length (State : Game_State) return Positive is
   begin
      return State.Length;
   end Snake_Length;

   function Food (State : Game_State) return Position is
   begin
      return State.Food_Pos;
   end Food;

   function Score (State : Game_State) return Natural is
   begin
      return State.Score_Value;
   end Score;

   function Is_Game_Over (State : Game_State) return Boolean is
   begin
      return State.Game_Over_Flag;
   end Is_Game_Over;

   function Is_Snake_Cell (State : Game_State; Pos : Position) return Boolean is
   begin
      for I in 1 .. State.Length loop
         if State.Snake (I) = Pos then
            return True;
         end if;
      end loop;
      return False;
   end Is_Snake_Cell;

end Snake_Game;
