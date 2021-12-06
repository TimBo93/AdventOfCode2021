with Ada.Directories; use Ada.Directories;

with  Ada.Strings.Unbounded;
with  Ada.Text_IO.Unbounded_IO; use Ada.Text_IO.Unbounded_IO ;

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO;

with Ada.Containers.Vectors;
use  Ada.Containers;

procedure Main is

   nameOk : boolean := false;
   fileExists : boolean;
   fileName : string := "input.txt";
   File : File_Type;

   type AgeIndex is range 0 .. 8;

   type PopulationByAge is
     array (AgeIndex) of Long_Long_Integer;

   Population : PopulationByAge := (0, 0, 0, 0, 0, 0, 0, 0, 0);


   procedure Render is
   begin
      for Indx in AgeIndex'Range loop
         Ada.Text_IO.Put (AgeIndex'Image(Indx) & ": " & Long_Long_Integer'Image(Population(Indx)) & "x | ");
      end loop;

      Ada.Text_IO.Put_Line("");
   end Render;


   procedure SimulateDay is
      nextPopulation: PopulationByAge := (0, 0, 0, 0, 0, 0, Population(AgeIndex(0)), 0, Population(AgeIndex(0)));
   begin
      -- iterate over "age"
      for Indx in AgeIndex'First..AgeIndex'Last-1 loop
         -- Ada.Text_IO.Put (AgeIndex'Image(Indx));
         nextPopulation(Indx) := nextPopulation(Indx) + Population(Indx + 1);
      end loop;
      Population := nextPopulation;
   end SimulateDay;

   function OverallSum return Long_Long_Integer is
      sum: Long_Long_Integer := 0;
   begin
      for Indx in AgeIndex'Range loop
         sum := sum + Long_Long_Integer(Population(Indx));
      end loop;
      return sum;
   end OverallSum;

begin
   fileExists := Exists(fileName);

   if fileExists then
      Open (File => File,
         Mode => In_File,
         Name => fileName);

      declare
         line : string := Get_Line (File);

         IntegerVariable: Integer;
         IntLast        : Natural := 1;

      begin
         Ada.Text_IO.Put_Line (line);

         while IntLast <= Line'Last loop
            Ada.Integer_Text_IO.Get
               (From => line(IntLast..line'Last), Item => IntegerVariable, Last => IntLast);

            Ada.Text_IO.Put_Line (Integer'Image(IntegerVariable));

            IntLast := IntLast + 2;

            Population(AgeIndex(IntegerVariable)) := Population(AgeIndex(IntegerVariable)) + 1;
         end loop;
      end;
   else
      Ada.Text_IO.Put_Line("input.txt file not found");
   end if;

   for i in 1..256 loop
      SimulateDay;
   end loop;

   Render;

   Ada.Text_IO.Put_Line("Overall sum is " & Long_Long_Integer'Image(OverallSum));
end Main;

