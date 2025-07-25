--
--  Copyright (C) 2020-2025, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with VSS.Strings.Character_Iterators;
with VSS.String_Vectors;
with VSS.Strings;

with Test_Support;

procedure Test_String_Vector is

   use type VSS.Strings.Virtual_String;
   use type VSS.String_Vectors.Virtual_String_Vector;

   LF  : constant Wide_Wide_Character := Wide_Wide_Character'Val (16#00_000A#);
   VT  : constant Wide_Wide_Character := Wide_Wide_Character'Val (16#00_000B#);
   FF  : constant Wide_Wide_Character := Wide_Wide_Character'Val (16#00_000C#);
   CR  : constant Wide_Wide_Character := Wide_Wide_Character'Val (16#00_000D#);
   NEL : constant Wide_Wide_Character := Wide_Wide_Character'Val (16#00_0085#);
   LS  : constant Wide_Wide_Character := Wide_Wide_Character'Val (16#00_2028#);
   PS  : constant Wide_Wide_Character := Wide_Wide_Character'Val (16#00_2029#);

   --  Testsuites

   procedure Test_Virtual_String_Vector;

   --  Testcases

   procedure Test_Legacy_Tests;
   procedure Test_Multiply_Operator;
   procedure Test_Join_String;
   procedure Test_Join_Lines;
   procedure Test_Is_Empty;
   procedure Test_Append_Vector;
   procedure Test_Concatenation_Vector;
   procedure Test_Clear;
   procedure Test_Contains;
   procedure Test_Delete;
   procedure Test_Prepend;

   ------------------------
   -- Test_Append_Vector --
   ------------------------

   procedure Test_Append_Vector is
      V1 : VSS.String_Vectors.Virtual_String_Vector;
      V2 : VSS.String_Vectors.Virtual_String_Vector;
      V3 : VSS.String_Vectors.Virtual_String_Vector;

   begin
      Test_Support.Assert (V1.Is_Empty);
      Test_Support.Assert (V1.First_Index = 1);
      Test_Support.Assert (V1.Last_Index = 0);
      Test_Support.Assert (V1.Length = 0);

      V1.Append ("line 1.1");
      V1.Append ("line 1.2");
      Test_Support.Assert (not V1.Is_Empty);
      Test_Support.Assert (V1.First_Index = 1);
      Test_Support.Assert (V1.Last_Index = 2);
      Test_Support.Assert (V1.Length = 2);

      V2.Append ("line 2.1");
      V2.Append ("line 2.2");
      V2.Append ("line 2.3");
      Test_Support.Assert (not V2.Is_Empty);
      Test_Support.Assert (V2.First_Index = 1);
      Test_Support.Assert (V2.Last_Index = 3);
      Test_Support.Assert (V2.Length = 3);

      V3.Append (V1);
      V3.Append (V2);
      Test_Support.Assert (not V3.Is_Empty);
      Test_Support.Assert (V3.First_Index = 1);
      Test_Support.Assert (V3.Last_Index = 5);
      Test_Support.Assert (V3.Length = 5);

      Test_Support.Assert (V3.Element (1) = "line 1.1");
      Test_Support.Assert (V3.Element (2) = "line 1.2");
      Test_Support.Assert (V3.Element (3) = "line 2.1");
      Test_Support.Assert (V3.Element (4) = "line 2.2");
      Test_Support.Assert (V3.Element (5) = "line 2.3");
   end Test_Append_Vector;

   ----------------
   -- Test_Clear --
   ----------------

   procedure Test_Clear is
      V1 : VSS.String_Vectors.Virtual_String_Vector;
      V2 : VSS.String_Vectors.Virtual_String_Vector;

   begin
      V1.Append ("line 1");
      Test_Support.Assert (not V1.Is_Empty);
      Test_Support.Assert (V1.First_Index = 1);
      Test_Support.Assert (V1.Last_Index = 1);
      Test_Support.Assert (V1.Length = 1);

      V2 := V1;
      Test_Support.Assert (not V2.Is_Empty);
      Test_Support.Assert (V2.First_Index = 1);
      Test_Support.Assert (V2.Last_Index = 1);
      Test_Support.Assert (V2.Length = 1);

      V1.Clear;
      Test_Support.Assert (V1.Is_Empty);
      Test_Support.Assert (V1.First_Index = 1);
      Test_Support.Assert (V1.Last_Index = 0);
      Test_Support.Assert (V1.Length = 0);
      Test_Support.Assert (not V2.Is_Empty);
      Test_Support.Assert (V2.First_Index = 1);
      Test_Support.Assert (V2.Last_Index = 1);
      Test_Support.Assert (V2.Length = 1);
   end Test_Clear;

   -------------------------------
   -- Test_Concatenation_Vector --
   -------------------------------

   procedure Test_Concatenation_Vector is
      V1 : constant VSS.String_Vectors.Virtual_String_Vector := ["a", "b"];
      V2 : constant VSS.String_Vectors.Virtual_String_Vector := ["c"];
      R  : VSS.String_Vectors.Virtual_String_Vector;

   begin
      R := V1 & V2;

      Test_Support.Assert (not R.Is_Empty);
      Test_Support.Assert (R.Length = 3);
      Test_Support.Assert (R (1) = "a");
      Test_Support.Assert (R (2) = "b");
      Test_Support.Assert (R (3) = "c");
   end Test_Concatenation_Vector;

   -------------------
   -- Test_Contains --
   -------------------

   procedure Test_Contains is
      V1 : VSS.String_Vectors.Virtual_String_Vector;
      V2 : VSS.String_Vectors.Virtual_String_Vector;

   begin
      V1.Append ("abc");
      V1.Append (VSS.Strings.Empty_Virtual_String);
      V1.Append ("def");

      Test_Support.Assert (V1.Contains ("abc"));
      Test_Support.Assert (V1.Contains (""));
      Test_Support.Assert (V1.Contains ("def"));
      Test_Support.Assert (not V1.Contains ("xyz"));

      Test_Support.Assert (not V2.Contains ("abc"));
   end Test_Contains;

   -----------------
   -- Test_Delete --
   -----------------

   procedure Test_Delete is
      V1 : VSS.String_Vectors.Virtual_String_Vector;

   begin
      V1.Append ("abc");
      V1.Append (VSS.Strings.Empty_Virtual_String);
      V1.Append ("def");

      V1.Delete (2);
      Test_Support.Assert (not V1.Is_Empty);
      Test_Support.Assert (V1.First_Index = 1);
      Test_Support.Assert (V1.Last_Index = 2);
      Test_Support.Assert (V1.Length = 2);
      Test_Support.Assert (V1 (1) = "abc");
      Test_Support.Assert (V1 (2) = "def");

      V1.Delete_Last;
      Test_Support.Assert (not V1.Is_Empty);
      Test_Support.Assert (V1.First_Index = 1);
      Test_Support.Assert (V1.Last_Index = 1);
      Test_Support.Assert (V1.Length = 1);
      Test_Support.Assert (V1 (1) = "abc");

      V1.Delete_Last;
      Test_Support.Assert (V1.Is_Empty);
      Test_Support.Assert (V1.First_Index = 1);
      Test_Support.Assert (V1.Last_Index = 0);
      Test_Support.Assert (V1.Length = 0);
   end Test_Delete;

   -------------------
   -- Test_Is_Empty --
   -------------------

   procedure Test_Is_Empty is
      V1 : VSS.String_Vectors.Virtual_String_Vector;
      V2 : VSS.String_Vectors.Virtual_String_Vector;

   begin
      V2.Append ("line 1");

      Test_Support.Assert (V1.Is_Empty);
      Test_Support.Assert (not V2.Is_Empty);
   end Test_Is_Empty;

   ---------------------
   -- Test_Join_Lines --
   ---------------------

   procedure Test_Join_Lines is
   begin
      --  Join two lines with all available line termitators.

      declare
         Lines      : VSS.String_Vectors.Virtual_String_Vector;

         Expected_CR   : constant VSS.Strings.Virtual_String :=
           VSS.Strings.To_Virtual_String
             ("line 1" & CR & "line 2" & CR);
         Expected_LF   : constant VSS.Strings.Virtual_String :=
           VSS.Strings.To_Virtual_String
             ("line 1" & LF & "line 2" & LF);
         Expected_CRLF : constant VSS.Strings.Virtual_String :=
           VSS.Strings.To_Virtual_String
             ("line 1" & CR & LF & "line 2" & CR & LF);
         Expected_NEL   : constant VSS.Strings.Virtual_String :=
           VSS.Strings.To_Virtual_String
             ("line 1" & NEL & "line 2" & NEL);
         Expected_VT   : constant VSS.Strings.Virtual_String :=
           VSS.Strings.To_Virtual_String
             ("line 1" & VT & "line 2" & VT);
         Expected_FF   : constant VSS.Strings.Virtual_String :=
           VSS.Strings.To_Virtual_String
             ("line 1" & FF & "line 2" & FF);
         Expected_LS   : constant VSS.Strings.Virtual_String :=
           VSS.Strings.To_Virtual_String
             ("line 1" & LS & "line 2" & LS);
         Expected_PS   : constant VSS.Strings.Virtual_String :=
           VSS.Strings.To_Virtual_String
             ("line 1" & PS & "line 2" & PS);

      begin
         Lines.Append ("line 1");
         Lines.Append ("line 2");

         Test_Support.Assert
           (Lines.Join_Lines (VSS.Strings.CR) = Expected_CR);
         Test_Support.Assert
           (Lines.Join_Lines (VSS.Strings.LF) = Expected_LF);
         Test_Support.Assert
           (Lines.Join_Lines (VSS.Strings.CRLF) = Expected_CRLF);
         Test_Support.Assert
           (Lines.Join_Lines (VSS.Strings.NEL) = Expected_NEL);
         Test_Support.Assert
           (Lines.Join_Lines (VSS.Strings.VT) = Expected_VT);
         Test_Support.Assert
           (Lines.Join_Lines (VSS.Strings.FF) = Expected_FF);
         Test_Support.Assert
           (Lines.Join_Lines (VSS.Strings.LS) = Expected_LS);
         Test_Support.Assert
           (Lines.Join_Lines (VSS.Strings.PS) = Expected_PS);
      end;

      --  Join lines without line terminator sequence for last line

      declare
         Lines      : VSS.String_Vectors.Virtual_String_Vector;

         Expected_CR   : constant VSS.Strings.Virtual_String :=
           VSS.Strings.To_Virtual_String
             ("line 1" & CR & "line 2" & CR & "line 3");
         Expected_LF   : constant VSS.Strings.Virtual_String :=
           VSS.Strings.To_Virtual_String
             ("line 1" & LF & "line 2" & LF & "line 3");
         Expected_CRLF : constant VSS.Strings.Virtual_String :=
           VSS.Strings.To_Virtual_String
             ("line 1" & CR & LF & "line 2" & CR & LF & "line 3");
         Expected_NEL   : constant VSS.Strings.Virtual_String :=
           VSS.Strings.To_Virtual_String
             ("line 1" & NEL & "line 2" & NEL & "line 3");
         Expected_VT   : constant VSS.Strings.Virtual_String :=
           VSS.Strings.To_Virtual_String
             ("line 1" & VT & "line 2" & VT & "line 3");
         Expected_FF   : constant VSS.Strings.Virtual_String :=
           VSS.Strings.To_Virtual_String
             ("line 1" & FF & "line 2" & FF & "line 3");
         Expected_LS   : constant VSS.Strings.Virtual_String :=
           VSS.Strings.To_Virtual_String
             ("line 1" & LS & "line 2" & LS & "line 3");
         Expected_PS   : constant VSS.Strings.Virtual_String :=
           VSS.Strings.To_Virtual_String
             ("line 1" & PS & "line 2" & PS & "line 3");

      begin
         Lines.Append ("line 1");
         Lines.Append ("line 2");
         Lines.Append ("line 3");

         Test_Support.Assert
           (Lines.Join_Lines (VSS.Strings.CR, False) = Expected_CR);
         Test_Support.Assert
           (Lines.Join_Lines (VSS.Strings.LF, False) = Expected_LF);
         Test_Support.Assert
           (Lines.Join_Lines (VSS.Strings.CRLF, False) = Expected_CRLF);
         Test_Support.Assert
           (Lines.Join_Lines (VSS.Strings.NEL, False) = Expected_NEL);
         Test_Support.Assert
           (Lines.Join_Lines (VSS.Strings.VT, False) = Expected_VT);
         Test_Support.Assert
           (Lines.Join_Lines (VSS.Strings.FF, False) = Expected_FF);
         Test_Support.Assert
           (Lines.Join_Lines (VSS.Strings.LS, False) = Expected_LS);
         Test_Support.Assert
           (Lines.Join_Lines (VSS.Strings.PS, False) = Expected_PS);
      end;

      --  Empty vector case

      declare
         Lines : VSS.String_Vectors.Virtual_String_Vector;

      begin
         Test_Support.Assert (Lines.Join_Lines (VSS.Strings.CR).Is_Empty);
      end;
   end Test_Join_Lines;

   ----------------------
   -- Test_Join_String --
   ----------------------

   procedure Test_Join_String is
   begin
      --  Usual case

      declare
         V : constant VSS.String_Vectors.Virtual_String_Vector :=
           ["ABC", "DEF", "GHI"];

      begin
         Test_Support.Assert (V.Join ("") = "ABCDEFGHI");
         Test_Support.Assert (V.Join (",") = "ABC,DEF,GHI");
         Test_Support.Assert (V.Join ("=>") = "ABC=>DEF=>GHI");
      end;

      --  Empty vector

      declare
         VE : VSS.String_Vectors.Virtual_String_Vector;

      begin
         Test_Support.Assert (VE.Join ("").Is_Empty);
         Test_Support.Assert (VE.Join ("").Is_Null);

         Test_Support.Assert (VE.Join (",").Is_Empty);
         Test_Support.Assert (VE.Join (",").Is_Null);

         Test_Support.Assert (VE.Join ("=>").Is_Empty);
         Test_Support.Assert (VE.Join ("=>").Is_Null);
      end;
   end Test_Join_String;

   -----------------------
   -- Test_Legacy_Tests --
   -----------------------

   procedure Test_Legacy_Tests is
      S1 : constant VSS.Strings.Virtual_String :=
        VSS.Strings.To_Virtual_String ("a");
      S2 : constant VSS.Strings.Virtual_String :=
        VSS.Strings.To_Virtual_String ("b");
      S3 : constant VSS.Strings.Virtual_String :=
        VSS.Strings.To_Virtual_String ("c");

      V1 : VSS.String_Vectors.Virtual_String_Vector;
      V2 : VSS.String_Vectors.Virtual_String_Vector;

      Revert : VSS.Strings.Virtual_String;

   begin
      --  Construct vector and check its content

      V1.Append (S1);
      V1.Append (VSS.Strings.Empty_Virtual_String);
      V1.Append (S2);

      Test_Support.Assert (V1.Length = 3);

      Test_Support.Assert (V1 (1) = S1);
      Test_Support.Assert (V1 (2).Is_Empty);
      Test_Support.Assert (V1 (3) = S2);

      Test_Support.Assert (V1.Last_Element = S2);

      --  Copy vector and append more data

      V2 := V1;

      V2.Append (S3);

      Test_Support.Assert (V2.Length = 4);

      Test_Support.Assert (V2 (1) = S1);
      Test_Support.Assert (V2 (2).Is_Empty);
      Test_Support.Assert (V2 (3) = S2);
      Test_Support.Assert (V2 (4) = S3);

      Test_Support.Assert (V2.Last_Element = S3);

      --  Check that first vector was not modified.

      if V1.Length /= 3 then
         raise Program_Error;
      end if;

      if V1 (1) /= S1 then
         raise Program_Error;
      end if;

      if not V1 (2).Is_Empty then
         raise Program_Error;
      end if;

      if V1 (3) /= S2 then
         raise Program_Error;
      end if;

      for Item of V2 loop
         if not Item.Is_Empty then
            Revert.Append (Item.At_First_Character.Element);
         end if;
      end loop;

      for Item of reverse V2 loop
         if not Item.Is_Empty then
            Revert.Append (Item.At_First_Character.Element);
         end if;
      end loop;

      if Revert /= VSS.Strings.To_Virtual_String ("abccba") then
         raise Program_Error;
      end if;

      --  Check vector "=" operator

      if V1 = V2 then  --  Case with V1.Length /= V2.Length
         raise Program_Error;
      end if;

      V1.Append (VSS.Strings.Empty_Virtual_String);

      if V1 = V2 then  --  Case with V1.Length = V2.Length
         raise Program_Error;
      end if;

      --  Check replace in a vector

      V1.Replace (4, S3);

      if V1 /= V2 then
         raise Program_Error;
      end if;
   end Test_Legacy_Tests;

   ----------------------------
   -- Test_Multiply_Operator --
   ----------------------------

   procedure Test_Multiply_Operator is
   begin
      declare
         V : constant VSS.String_Vectors.Virtual_String_Vector := 0 * "";

      begin
         Test_Support.Assert (V.Is_Empty);
      end;

      declare
         V : constant VSS.String_Vectors.Virtual_String_Vector := 0 * "ABC";

      begin
         Test_Support.Assert (V.Is_Empty);
      end;

      declare
         V : constant VSS.String_Vectors.Virtual_String_Vector := 1 * "";

      begin
         Test_Support.Assert (not V.Is_Empty);
         Test_Support.Assert (V.Length = 1);
         Test_Support.Assert (V.First_Element.Is_Empty);
      end;

      declare
         V : constant VSS.String_Vectors.Virtual_String_Vector := 1 * "ABC";

      begin
         Test_Support.Assert (not V.Is_Empty);
         Test_Support.Assert (V.Length = 1);
         Test_Support.Assert (V.First_Element = "ABC");
      end;

      declare
         V : constant VSS.String_Vectors.Virtual_String_Vector := 3 * "";

      begin
         Test_Support.Assert (not V.Is_Empty);
         Test_Support.Assert (V.Length = 3);
         Test_Support.Assert (for all J in 1 .. 3 => V (J).Is_Empty);
      end;

      declare
         V : constant VSS.String_Vectors.Virtual_String_Vector := 3 * "ABC";

      begin
         Test_Support.Assert (not V.Is_Empty);
         Test_Support.Assert (V.Length = 3);
         Test_Support.Assert (for all J in 1 .. 3 => V (J) = "ABC");
      end;
   end Test_Multiply_Operator;

   ------------------
   -- Test_Prepend --
   ------------------

   procedure Test_Prepend is
      V : VSS.String_Vectors.Virtual_String_Vector;

   begin
      V.Prepend ("a");
      V.Prepend ("b");
      V.Prepend ("c");

      Test_Support.Assert (not V.Is_Empty);
      Test_Support.Assert (V.First_Index = 1);
      Test_Support.Assert (V.Last_Index = 3);
      Test_Support.Assert (V.Length = 3);
      Test_Support.Assert (V (1) = "c");
      Test_Support.Assert (V (2) = "b");
      Test_Support.Assert (V (3) = "a");
   end Test_Prepend;

   --------------------------------
   -- Test_Virtual_String_Vector --
   --------------------------------

   procedure Test_Virtual_String_Vector is
   begin
      Test_Support.Run_Testcase
        (Test_Legacy_Tests'Access, "Various legacy tests");
      Test_Support.Run_Testcase
        (Test_Join_String'Access, "Join String Separator");
      Test_Support.Run_Testcase (Test_Join_Lines'Access, "Join_Lines");
      Test_Support.Run_Testcase (Test_Is_Empty'Access, "Is_Empty");
      Test_Support.Run_Testcase
        (Test_Multiply_Operator'Access, "Natural * Virtual_String");
      Test_Support.Run_Testcase (Test_Append_Vector'Access, "Append (Vector)");
      Test_Support.Run_Testcase (Test_Clear'Access, "Clear");
      Test_Support.Run_Testcase (Test_Contains'Access, "Contains");
      Test_Support.Run_Testcase (Test_Delete'Access, "Delete");
      Test_Support.Run_Testcase (Test_Prepend'Access, "Prepend");
      Test_Support.Run_Testcase
        (Test_Concatenation_Vector'Access, "Concatenation of vectors");
   end Test_Virtual_String_Vector;

begin
   Test_Support.Run_Testsuite
     (Test_Virtual_String_Vector'Access, "Virtual_String_Vector");
end Test_String_Vector;
