package Snake_Game is
   Grid_Width  : constant Positive := 20;
   Grid_Height : constant Positive := 15;
   Max_Length  : constant Positive := Grid_Width * Grid_Height;

   type Direction is (Up, Down, Left, Right);

   type Position is record
      X : Positive;
      Y : Positive;
   end record;

   type Game_State is private;

   procedure Initialize (State : out Game_State; Seed : Positive := 1);
   procedure Restart (State : in out Game_State);
   procedure Set_Direction (State : in out Game_State; Dir : Direction);
   procedure Tick (State : in out Game_State);

   procedure Set_Food (State : in out Game_State; Pos : Position);

   function Snake_Head (State : Game_State) return Position;
   function Snake_Length (State : Game_State) return Positive;
   function Food (State : Game_State) return Position;
   function Score (State : Game_State) return Natural;
   function Is_Game_Over (State : Game_State) return Boolean;
   function Is_Snake_Cell (State : Game_State; Pos : Position) return Boolean;

private
   type Position_Array is array (Positive range 1 .. Max_Length) of Position;

   type Game_State is record
      Snake          : Position_Array;
      Length         : Positive := 1;
      Current_Dir    : Direction := Right;
      Pending_Dir    : Direction := Right;
      Food_Pos       : Position := (X => 1, Y => 1);
      Score_Value    : Natural := 0;
      Game_Over_Flag : Boolean := False;
      Seed_Value     : Positive := 1;
   end record;
end Snake_Game;
