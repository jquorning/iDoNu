--
--  The author disclaims copyright to this source code.  In place of
--  a legal notice, here is a blessing:
--
--    May you do good and not evil.
--    May you find forgiveness for yourself and forgive others.
--    May you share freely, not taking more than you give.
--

with Ada.Text_IO;
with Ada.Strings.Unbounded;

with AWS.MIME;
with AWS.Templates;
with AWS.Parameters;

with GNAT.Traceback.Symbolic;

with Parser;
with Database.Jobs;
with Web_IO;
with Types;

package body Web_Callbacks is

   Web_Base : constant String := "../web/";
   Translations : AWS.Templates.Translate_Set;


   function Job_Name (Job : in Types.Job_Id)
                     return String;
   --  Get name of current job.

   procedure Associate (Placeholder : String;
                        Value       : String);
   --  Update template translation Placeholder with Value.

   procedure Serve_Main_Page (Request : in AWS.Status.Data);
   --  Build main web page "/"


   procedure Associate (Placeholder : String;
                        Value       : String)
   is
   begin
      AWS.Templates.Insert (Translations,
                            AWS.Templates.Assoc (Placeholder, Value));
   end Associate;


   procedure Initialize is
   begin
      --  Static translations
      Associate ("COMMAND_TABLE", Web_IO.Help_Image);
   end Initialize;


   function Job_Name (Job : in Types.Job_Id)
                     return String
   is
      use Database.Jobs;
      use Types;
      Top_Jobs : constant Job_Sets.Vector :=
        Get_Jobs (Database.Jobs.Top_Level);
   begin
      for J of Top_Jobs loop
         if Job = J.Id then
            return Ada.Strings.Unbounded.To_String (J.Title);
         end if;
      end loop;
      return "UNKNOWN=XXX";
   end Job_Name;


   procedure Serve_Main_Page (Request : in AWS.Status.Data) is
      List : constant AWS.Parameters.List := AWS.Status.Parameters (Request);
      CMD  : constant String := AWS.Parameters.Get (List, "cmd");
   begin
      Parser.Parse_Input (CMD);

      Associate ("CUR_JOB_NAME", Job_Name (Database.Jobs.Get_Current_Job));
      Associate ("JOBS_LIST",    Web_IO.Jobs_Image);

      Associate ("JOB_INFORMATION",
                 Web_IO.Job_Image (Database.Jobs.Get_Current_Job));
      Associate ("LAST_COMMAND",    Parser.Get_Last_Command);
   end Serve_Main_Page;

   ----------
   -- Main --
   ----------

   function Main (Request : in AWS.Status.Data)
                 return AWS.Response.Data
   is
      use AWS;

      URI      : constant String          := Status.URI (Request);
      Filename : constant String          := URI (URI'First + 1 .. URI'Last);
   begin

      if
        URI = "/stylesheets/print.css" or
        URI = "/stylesheets/main.css" or
        URI = "/stylesheets/boilerplate.css" or
        URI = "/css/rg.css"
      then
         return AWS.Response.Build
           (MIME.Text_CSS,
            Message_Body => Templates.Parse (Web_Base & Filename));

      elsif URI = "/favicon.ico" then
         Ada.Text_IO.Put_Line ("Serving ikon " & URI);
         return AWS.Response.Build
           (MIME.Text_HTML, Message_Body
              => Templates.Parse (Web_Base & "favicon.ico"));

      elsif URI = "/" then
         Serve_Main_Page (Request);
         return AWS.Response.Build
           (MIME.Text_HTML,
            Message_Body => AWS.Templates.Parse (Web_Base & "main.thtml",
                                                 Translations));

      elsif URI = "/test" then
         return AWS.Response.Build
           (MIME.Text_HTML,
            Message_Body => "<html><head><title>Test</title></head>" &
              "<body><h1>Test</html>");

      else
         Ada.Text_IO.Put_Line ("URI is " & URI);
         Ada.Text_IO.Put_Line ("Filename is " & Filename);
         return AWS.Response.Build
           (MIME.Text_HTML,
            Message_Body => Templates.Parse (Web_Base & "fejl.html"));
      end if;

   exception

      when others =>
         declare --  Call_Stack
            Trace  : GNAT.Traceback.Tracebacks_Array (1 .. 100);
            Length : Natural;
         begin
            GNAT.Traceback.Call_Chain (Trace, Length);
            Ada.Text_IO.Put_Line
              (GNAT.Traceback.Symbolic.Symbolic_Traceback
                 (Trace (1 .. Length)));
         end;
         raise;

   end Main;


end Web_Callbacks;
