with Ada.Exceptions;
with Ada.Text_IO;
with Snake_Game;

procedure Snake_Game_Tests is
   use Ada.Text_IO;

   procedure Assert (Condition : Boolean; Message : String) is
   begin
      if not Condition then
         raise Program_Error with Message;
      end if;
   end Assert;

   procedure Test_Movement is
      S         : Snake_Game.Game_State;
      Start_Head : Snake_Game.Position;
   begin
      Snake_Game.Initialize (S, Seed => 1);
      Start_Head := Snake_Game.Snake_Head (S);
      Snake_Game.Tick (S);

      Assert (Snake_Game.Snake_Head (S).X = Start_Head.X + 1, "head should move right");
      Assert (Snake_Game.Snake_Head (S).Y = Start_Head.Y, "head y should stay same");
   end Test_Movement;

   procedure Test_Growth is
      S         : Snake_Game.Game_State;
      Start_Head : Snake_Game.Position;
   begin
      Snake_Game.Initialize (S, Seed => 2);
      Start_Head := Snake_Game.Snake_Head (S);
      Snake_Game.Set_Food (S, (X => Start_Head.X + 1, Y => Start_Head.Y));
      Snake_Game.Tick (S);

      Assert (Snake_Game.Snake_Length (S) = 4, "snake should grow after eating");
      Assert (Snake_Game.Score (S) = 1, "score should increment after eating");
   end Test_Growth;

   procedure Test_Wall_Collision is
      S : Snake_Game.Game_State;
   begin
      Snake_Game.Initialize (S, Seed => 3);
      Snake_Game.Set_Direction (S, Snake_Game.Left);
      for I in 1 .. Snake_Game.Grid_Width loop
         Snake_Game.Tick (S);
         exit when Snake_Game.Is_Game_Over (S);
      end loop;

      Assert (Snake_Game.Is_Game_Over (S), "hitting wall should end game");
   end Test_Wall_Collision;

   procedure Test_Food_Placement is
      S : Snake_Game.Game_State;
   begin
      Snake_Game.Initialize (S, Seed => 4);
      Assert
        (not Snake_Game.Is_Snake_Cell (S, Snake_Game.Food (S)),
         "food should not spawn inside snake");
   end Test_Food_Placement;

begin
   Test_Movement;
   Test_Growth;
   Test_Wall_Collision;
   Test_Food_Placement;
   Put_Line ("All snake game tests passed.");

exception
   when E : others =>
      Put_Line ("Test failure: " & Ada.Exceptions.Exception_Message (E));
      raise;
end Snake_Game_Tests;
