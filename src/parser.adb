--
--  Parser body
--

with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;
with Ada.Calendar;

with Database.Events;
with Commands;
with Terminal_IO;
with CSV_IO;

package body Parser is

   Run_Program  : Boolean := True;

   Last_Command : Ada.Strings.Unbounded.Unbounded_String;


   procedure Set (Command : in String);
   procedure Show (Command : in String);
   procedure Add (Command : in String);
   procedure Event (Command : in String);
   procedure Transfer (Command : in String);


   function Exit_Program return Boolean is
   begin
      return not Run_Program;
   end Exit_Program;


   procedure Set (Command : in String) is
      Space_Pos : constant Natural := Ada.Strings.Fixed.Index (Command, " ");
      First     : constant String
        := (if Space_Pos = 0 then Command
        else Command (Command'First .. Space_Pos - 1));
      Rest     : constant String
        := (if Space_Pos = 0 then ""
        else Ada.Strings.Fixed.Trim (Command (Space_Pos .. Command'Last),
                                     Ada.Strings.Both));
   begin
      if First = "list" then
         Database.Lists.Current := Database.Lookup_List (Rest);
      elsif First = "job" then
         Database.Jobs.Current  := Database.Lookup_Job (Rest);
      else
         raise Constraint_Error;
      end if;
   end Set;


   procedure Show (Command : in String) is
      Space_Pos : constant Natural := Ada.Strings.Fixed.Index (Command, " ");
      First     : constant String
        := (if Space_Pos = 0 then Command
        else Command (Command'First .. Space_Pos - 1));
--        Rest     : constant String
--          := (if Space_Pos = 0 then ""
--          else Command (Space_Pos .. Command'Last));
   begin
      if First = "list" then
         Commands.Show_List (Database.Lists.Current);
      elsif First = "job" then
         Terminal_IO.Show_Job (Database.Jobs.Current);
      else
         raise Constraint_Error;
      end if;
   end Show;


   procedure Add (Command : in String) is
      Space_Pos : constant Natural := Ada.Strings.Fixed.Index (Command, " ");
      First     : constant String
        := (if Space_Pos = 0 then Command
        else Command (Command'First .. Space_Pos - 1));
      Rest     : constant String
        := (if Space_Pos = 0 then ""
        else Command (Space_Pos .. Command'Last));
   begin
      if First = "job" then
         Commands.Create_Job
           (Database.Get_Job_Id,
            Ada.Strings.Fixed.Trim (Rest, Ada.Strings.Both),
            Database.Lists.Current);
      elsif First = "list" then
         Database.Create_List
           (Ada.Strings.Fixed.Trim (Rest, Ada.Strings.Both));
      else
         raise Constraint_Error;
      end if;
   end Add;


   procedure Event (Command : in String) is
      pragma Unreferenced (Command);
      --        Space_Pos : constant Natural
      --  := Ada.Strings.Fixed.Index (Command, " ");
--        First     : constant String
--          := (if Space_Pos = 0 then Command
--          else Command (Command'First .. Space_Pos - 1));
--        Rest     : constant String
--          := (if Space_Pos = 0 then ""
--          else Command (Space_Pos .. Command'Last));
      Id : Database.Events.Event_Id;
      pragma Unreferenced (Id);
   begin
      Database.Events.Add_Event (Database.Jobs.Current,
                                 Ada.Calendar.Clock,
                                 Database.Events.Deadline,
                                 Id);
   end Event;

   procedure Transfer (Command : in String) is
      use Database;
   begin
      Transfer (Job     => Jobs.Current,
                To_List => Lookup_List (Command));
   end Transfer;


   procedure Parse_Input (Input : in String) is
      Space_Pos : constant Natural := Ada.Strings.Fixed.Index (Input, " ");
      First     : constant String
        := (if Space_Pos = 0 then Input
        else Input (Input'First .. Space_Pos - 1));
      Rest     : constant String
        := (if Space_Pos = 0 then ""
        else Ada.Strings.Fixed.Trim (Input (Space_Pos .. Input'Last),
                                     Ada.Strings.Both));
   begin
      Last_Command := Ada.Strings.Unbounded.To_Unbounded_String (Input);
      if First = "" then
         null;
      elsif First = "quit" then
         Run_Program := False;
      elsif First = "help" then
         Terminal_IO.Put_Help;
      elsif First = "view" then
         Database.Get_Jobs (Database.Jobs,
                            List => Database.Lists.Current);
         Terminal_IO.Put_Jobs (Database.Jobs);
      elsif First = "lists" then
         Database.Get_Lists (Database.Lists);
         Terminal_IO.Put_Lists (Database.Lists);
      elsif First = "set" then
         Set (Rest);
      elsif First = "show" then
         Show (Rest);
      elsif First = "add" then
         Add (Rest);
      elsif First = "split" then
         raise Program_Error;
      elsif First = "move" then
         Transfer (Rest);
      elsif First = "trans" then
         Transfer (Rest);
      elsif First = "event" then
         Event (Rest);
      elsif First = "export" then
         CSV_IO.Export ("todo_text.csv");
      else
         Terminal_IO.Put_Error ("Unknown command: '" & Get_Last_Command & "'");
      end if;

   exception
      when Constraint_Error =>
         Terminal_IO.Put_Error ("Constraint_Error in parser");

   end Parse_Input;


   function Get_Last_Command return String is
   begin
      return Ada.Strings.Unbounded.To_String (Last_Command);
   end Get_Last_Command;


end Parser;
