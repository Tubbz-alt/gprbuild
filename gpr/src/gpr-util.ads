------------------------------------------------------------------------------
--                                                                          --
--                           GPR PROJECT MANAGER                            --
--                                                                          --
--          Copyright (C) 2001-2016, Free Software Foundation, Inc.         --
--                                                                          --
-- This library is free software;  you can redistribute it and/or modify it --
-- under terms of the  GNU General Public License  as published by the Free --
-- Software  Foundation;  either version 3,  or (at your  option) any later --
-- version. This library is distributed in the hope that it will be useful, --
-- but WITHOUT ANY WARRANTY;  without even the implied warranty of MERCHAN- --
-- TABILITY or FITNESS FOR A PARTICULAR PURPOSE.                            --
--                                                                          --
-- As a special exception under Section 7 of GPL version 3, you are granted --
-- additional permissions described in the GCC Runtime Library Exception,   --
-- version 3.1, as published by the Free Software Foundation.               --
--                                                                          --
-- You should have received a copy of the GNU General Public License and    --
-- a copy of the GCC Runtime Library Exception along with this program;     --
-- see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    --
-- <http://www.gnu.org/licenses/>.                                          --
--                                                                          --
------------------------------------------------------------------------------

--  Utilities for use in processing project files

with GPR.Osint; use GPR.Osint;
with GPR.Scans; use GPR.Scans;

package GPR.Util is

   Default_Config_Name : constant String := "default.cgpr";
   --  Name of the configuration file used by gprbuild and generated by
   --  gprconfig by default.

   Load_Standard_Base : Boolean := True;
   --  False when gprbuild is called with --db-

   procedure Set_Program_Name (N : String);
   --  Indicate the executable name, so that it can be displayed with
   --  Write_Program_Name below.

   procedure Write_Program_Name;
   --  Display the name of the executable in error mesages

   --------------
   -- Closures --
   --------------

   type Status_Type is
     (Success,
      Unknown_Error,
      Invalid_Project,
      No_Main,
      Invalid_Main,
      Incomplete_Closure);

   procedure Get_Closures
     (Project                  : Project_Id;
      In_Tree                  : Project_Tree_Ref;
      Mains                    : String_List;
      All_Projects             : Boolean := True;
      Include_Externally_Built : Boolean := False;
      Status                   : out Status_Type;
      Result                   : out String_List_Access);
   --  Return the list of source files in the closures of the Ada Mains in
   --  Result.
   --  The project and its project tree must have been parsed and processed.
   --  Mains is a list of single file names that are Ada sources of the project
   --  Project or of its subprojects.
   --  When All_Projects is False, the Mains must be sources of the Project and
   --  the sources of the closures that are sources of the imported subprojects
   --  are not included in the returned list.
   --  When All_Projects is True, mains may also be found in subprojects,
   --  including aggregated projects when Project is an aggregate project.
   --  When All_Projects is True, sources in the closures that are sources of
   --  externally built subprojects are included in the returned list only when
   --  Include_Externally_Built is True.
   --  Result is the list of path names in the closures.
   --  It is the responsibility of the caller to deallocate the Strings in
   --  Result and Result itself.
   --  When all the sources in the closures are found, Result is non null and
   --  Status is Success.
   --  When only a subset of the sources in the closures are found, Result is
   --  non null and Status is Incomplete_Closure.
   --  When there are other problems, Result is null and Status is different
   --  from Success or Incomplete_Closure.

   -------------------------
   -- Program termination --
   -------------------------

   procedure Fail_Program
     (Project_Tree   : Project_Tree_Ref;
      S              : String;
      Flush_Messages : Boolean := True;
      No_Message     : Boolean := False);
   --  Terminate program with a message and a fatal status code. Do not issue
   --  any message when No_Message is True.

   procedure Finish_Program
     (Project_Tree : Project_Tree_Ref;
      Exit_Code    : Exit_Code_Type := E_Success;
      S            : String := "";
      No_Message   : Boolean := False);
   --  Terminate program, with or without a message, setting the status code
   --  according to Fatal. This properly removes all temporary files. Do not
   --  issue any message when No_Message is True.

   procedure Duplicate
     (This   : in out Name_List_Index;
      Shared : Shared_Project_Tree_Data_Access);
   --  Duplicate a name list

   function Executable_Of
     (Project        : Project_Id;
      Shared         : Shared_Project_Tree_Data_Access;
      Main           : File_Name_Type;
      Index          : Int;
      Language       : String := "";
      Include_Suffix : Boolean := True) return File_Name_Type;
   --  Return the value of the attribute Builder'Executable for file Main in
   --  the project Project, if it exists. If there is no attribute Executable
   --  for Main, remove the suffix from Main; then, if the attribute
   --  Executable_Suffix is specified, add this suffix, otherwise add the
   --  standard executable suffix for the platform.
   --
   --  Language is the name of the programing language of the Main.
   --
   --  If Include_Suffix is true, then the ".exe" suffix (or any suffix defined
   --  in the config) will be added. The suffix defined by the user in his own
   --  project file is always taken into account. Otherwise, such a suffix is
   --  not added. In particular, the prefix should not be added if you are
   --  potentially testing for cross-platforms, since the suffix might not be
   --  known (its default value comes from the ...-gnatmake prefix).

   procedure Expect (The_Token : Token_Type; Token_Image : String);
   --  Check that the current token is The_Token. If it is not, then output
   --  an error message.

   function Executable_Prefix_Path return String;
   --  Return the absolute path parent directory of the directory where the
   --  current executable resides, if its directory is named "bin", otherwise
   --  return an empty string. When a directory is returned, it is guaranteed
   --  to end with a directory separator.

   function Locate_Directory
     (Dir_Name : String;
      Path     : String)
      return String_Access;
   --  Find directory Dir_Name in Path. Return absolute path of directory, or
   --  null if directory cannot be found. The caller is responsible for
   --  freeing the returned String_Access.

   procedure Put
     (Into_List  : in out Name_List_Index;
      From_List  : String_List_Id;
      In_Tree    : Project_Tree_Ref;
      Lower_Case : Boolean := False);
   --  Append From_List list to list Into_List

   type Name_Array_Type is array (Positive range <>) of Name_Id;

   function Split (Source : String; Separator : String) return Name_Array_Type;
   --  Split string Source into several, using Separator. The different
   --  occurences of Separator are not included in the result. The result
   --  includes no empty string.

   function Value_Of
     (Variable : Variable_Value;
      Default  : String) return String;
   --  Get the value of a single string variable. If Variable is a string list,
   --  is Nil_Variable_Value,or is defaulted, return Default.

   function Value_Of
     (Index    : Name_Id;
      In_Array : Array_Element_Id;
      Shared   : Shared_Project_Tree_Data_Access) return Name_Id;
   --  Get a single string array component. Returns No_Name if there is no
   --  component Index, if In_Array is null, or if the component is a String
   --  list. Depending on the attribute (only attributes may be associative
   --  arrays) the index may or may not be case sensitive. If the index is not
   --  case sensitive, it is first set to lower case before the search in the
   --  associative array.

   function Value_Of
     (Index                  : Name_Id;
      Src_Index              : Int := 0;
      In_Array               : Array_Element_Id;
      Shared                 : Shared_Project_Tree_Data_Access;
      Force_Lower_Case_Index : Boolean := False;
      Allow_Wildcards        : Boolean := False) return Variable_Value;
   --  Get a string array component (single String or String list). Returns
   --  Nil_Variable_Value if no component Index or if In_Array is null.
   --
   --  Depending on the attribute (only attributes may be associative arrays)
   --  the index may or may not be case sensitive. If the index is not case
   --  sensitive, it is first set to lower case before the search in the
   --  associative array.

   function Value_Of
     (Name                    : Name_Id;
      Index                   : Int := 0;
      Attribute_Or_Array_Name : Name_Id;
      In_Package              : Package_Id;
      Shared                  : Shared_Project_Tree_Data_Access;
      Force_Lower_Case_Index  : Boolean := False;
      Allow_Wildcards         : Boolean := False) return Variable_Value;
   --  In a specific package:
   --   - if there exists an array Attribute_Or_Array_Name with an index Name,
   --     returns the corresponding component (depending on the attribute, the
   --     index may or may not be case sensitive, see previous function),
   --   - otherwise if there is a single attribute Attribute_Or_Array_Name,
   --     returns this attribute,
   --   - otherwise, returns Nil_Variable_Value.
   --  If In_Package is null, returns Nil_Variable_Value.

   function Value_Of
     (Index     : Name_Id;
      In_Array  : Name_Id;
      In_Arrays : Array_Id;
      Shared    : Shared_Project_Tree_Data_Access) return Name_Id;
   --  Get a string array component in an array of an array list. Returns
   --  No_Name if there is no component Index, if In_Arrays is null, if
   --  In_Array is not found in In_Arrays or if the component is a String list.

   function Value_Of
     (Name      : Name_Id;
      In_Arrays : Array_Id;
      Shared    : Shared_Project_Tree_Data_Access) return Array_Element_Id;
   --  Returns a specified array in an array list. Returns No_Array_Element
   --  if In_Arrays is null or if Name is not the name of an array in
   --  In_Arrays. The caller must ensure that Name is in lower case.

   function Value_Of
     (Name        : Name_Id;
      In_Packages : Package_Id;
      Shared      : Shared_Project_Tree_Data_Access) return Package_Id;
   --  Returns a specified package in a package list. Returns No_Package
   --  if In_Packages is null or if Name is not the name of a package in
   --  Package_List. The caller must ensure that Name is in lower case.

   function Value_Of
     (Variable_Name : Name_Id;
      In_Variables  : Variable_Id;
      Shared        : Shared_Project_Tree_Data_Access) return Variable_Value;
   --  Returns a specified variable in a variable list. Returns null if
   --  In_Variables is null or if Variable_Name is not the name of a
   --  variable in In_Variables. Caller must ensure that Name is lower case.

   procedure Write_Str
     (S          : String;
      Max_Length : Positive;
      Separator  : Character);
   --  Output string S. If S is too long to fit in one
   --  line of Max_Length, cut it in several lines, using Separator as the last
   --  character of each line, if possible.

   type Text_File is limited private;
   --  Represents a text file (default is invalid text file)

   function Is_Valid (File : Text_File) return Boolean;
   --  Returns True if File designates an open text file that has not yet been
   --  closed.

   procedure Open (File : out Text_File; Name : String);
   --  Open a text file to read (File is invalid if text file cannot be opened)

   procedure Create (File : out Text_File; Name : String);
   --  Create a text file to write (File is invalid if text file cannot be
   --  created).

   function End_Of_File (File : Text_File) return Boolean;
   --  Returns True if the end of the text file File has been reached. Fails if
   --  File is invalid. Return True if File is an out file.

   procedure Get_Line
     (File : Text_File;
      Line : out String;
      Last : out Natural);
   --  Reads a line from an open text file (fails if File is invalid or in an
   --  out file).

   procedure Put (File : Text_File; S : String);
   procedure Put_Line (File : Text_File; Line : String);
   --  Output a string or a line to an out text file (fails if File is invalid
   --  or in an in file).

   procedure Close (File : in out Text_File);
   --  Close an open text file. File becomes invalid. Fails if File is already
   --  invalid or if an out file cannot be closed successfully.

   -----------------------
   -- Source info files --
   -----------------------

   --  A source info file is a text file that contains information on the
   --  significant sources of a project tree.
   --
   --  Only sources that are not excluded and are not replaced by another
   --  source in an extending projects are described in a source info file.
   --
   --  Each source is described with 4 lines, followed by optional lines,
   --  followed by an empty line.
   --
   --  The four lines in every entry are
   --    - the name of the project
   --    - the name of the language
   --    - the kind of source: SPEC, IMPL (body) OR SEP (subunit).
   --    - the path name of the source
   --
   --  The optional lines are:
   --    - if the canonical case path name is not the same as the path name
   --      to be displayed, a line starting with "P=" followed by the canonical
   --      case path name.
   --    - if the language is unit based (Ada), a line starting with "U="
   --      followed by the unit name.
   --    - if the unit is part of a multi-unit source, a line starting with
   --      "I=" followed by the index in the multi-unit source.
   --    - if the source is a naming exception declared in its project, a line
   --      containing "N=Y".
   --    - if it is an inherited naming exception, a line containng "N=I".

   procedure Write_Source_Info_File (Tree : Project_Tree_Ref);
   --  Create a new source info file, with the path name specified in the
   --  project tree data. Issue a warning if it is not possible to create
   --  the new file.

   procedure Read_Source_Info_File (Tree : Project_Tree_Ref);
   --  Check if there is a source info file specified for the project Tree. If
   --  so, attempt to read it. If the file exists and is successfully read, set
   --  the flag Source_Info_File_Exists to True for the tree.

   type Source_Info_Data is record
      Project           : Name_Id;
      Language          : Name_Id;
      Kind              : Source_Kind;
      Display_Path_Name : Name_Id;
      Path_Name         : Name_Id;
      Unit_Name         : Name_Id               := No_Name;
      Index             : Int                   := 0;
      Naming_Exception  : Naming_Exception_Type := No;
   end record;
   --  Data read from a source info file for a single source

   type Source_Info is access all Source_Info_Data;
   No_Source_Info : constant Source_Info := null;

   type Source_Info_Iterator is private;
   --  Iterator to get the sources for a single project

   procedure Initialize
     (Iter        : out Source_Info_Iterator;
      For_Project : Name_Id);
   --  Initialize Iter for the project

   function Source_Info_Of (Iter : Source_Info_Iterator) return Source_Info;
   --  Get the source info for the source corresponding to the current value of
   --  the iterator. Returns No_Source_Info if there is no source corresponding
   --  to the iterator.

   procedure Next (Iter : in out Source_Info_Iterator);
   --  Advance the iterator to the next source in the project

   function Is_Ada_Predefined_File_Name
     (Fname : File_Name_Type) return Boolean;
   --  Return True if Fname is a runtime source file name

   function Is_Ada_Predefined_Unit (Unit : String) return Boolean;
   --  Return True if Unit is an Ada runtime unit

   generic
      with procedure Action (Source : Source_Id);
   procedure For_Interface_Sources
     (Tree    : Project_Tree_Ref;
      Project : Project_Id);
   --  Call Action for every sources that are needed to use Project. This is
   --  either the sources corresponding to the units in attribute Interfaces
   --  or all sources of the project. Note that only the bodies that are
   --  needed (because the unit is generic or contains some inline pragmas)
   --  are handled. This routine must be called only when the project has
   --  been built successfully.

   function Relative_Path (Pathname : String; To : String) return String;
   --  Returns the relative pathname which corresponds to Pathname when
   --  starting from directory to. Both Pathname and To must be absolute paths.

   function Create_Name (Name : String) return File_Name_Type;
   function Create_Name (Name : String) return Name_Id;
   function Create_Name (Name : String) return Path_Name_Type;
   --  Get an id for a name

   function Is_Subunit (Source : Source_Id) return Boolean;
   --  Return True if source is a subunit

   procedure Initialize_Source_Record
     (Source : Source_Id;
      Always : Boolean := False);
   --  Get information either about the source file, or the object and
   --  dependency file, as well as their timestamps.
   --  When Always is True, initialize Source even if it has already been
   --  initialized.

   function Source_Dir_Of (Source : Source_Id) return String;
   --  Returns the directory of the source file

   procedure Get_Switches
     (Source       : Source_Id;
      Pkg_Name     : Name_Id;
      Project_Tree : Project_Tree_Ref;
      Value        : out Variable_Value;
      Is_Default   : out Boolean);
   procedure Get_Switches
     (Source_File         : File_Name_Type;
      Source_Lang         : Name_Id;
      Source_Prj          : Project_Id;
      Pkg_Name            : Name_Id;
      Project_Tree        : Project_Tree_Ref;
      Value               : out Variable_Value;
      Is_Default          : out Boolean;
      Test_Without_Suffix : Boolean := False;
      Check_ALI_Suffix    : Boolean := False);
   --  Compute the switches (Compilation switches for instance) for the given
   --  file. This checks various attributes to see if there are file specific
   --  switches, or else defaults on the switches for the corresponding
   --  language. Is_Default is set to False if there were file-specific
   --  switches. Source_File can be set to No_File to force retrieval of the
   --  default switches. If Test_Without_Suffix is True, and there is no "for
   --  Switches(Source_File) use", then this procedure also tests without the
   --  extension of the filename. If Test_Without_Suffix is True and
   --  Check_ALI_Suffix is True, then we also replace the file extension with
   --  ".ali" when testing.

   function Object_Project (Project : Project_Id) return Project_Id;
   --  For a non aggregate project, returns the project. For an aggrete project
   --  or an aggregate library project, returns an aggregated project that is
   --  not an aggregate project and that has a writeable object directory. If
   --  there is no such project, returns No_Project.

private
   type Text_File_Data is record
      FD                  : File_Descriptor := Invalid_FD;
      Out_File            : Boolean := False;
      Buffer              : String (1 .. 100_000);
      Buffer_Len          : Natural := 0;
      Cursor              : Natural := 0;
      End_Of_File_Reached : Boolean := False;
   end record;

   type Text_File is access Text_File_Data;

   type Source_Info_Iterator is record
      Info : Source_Info;
      Next : Natural;
   end record;

end GPR.Util;
