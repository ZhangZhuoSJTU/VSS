--
--  Copyright (C) 2022-2025, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with VSS.Strings.Character_Iterators;
with VSS.Strings.Line_Iterators;
with VSS.String_Vectors;

with Test_Support;

procedure Test_String is

   use type VSS.Strings.Virtual_String;

   procedure Test_Virtual_String;
   --  Run Virtual_String testsuite

   procedure Test_Ampersand_Character;
   procedure Test_Asterisk_Character;
   procedure Test_Delete_Pattern_Character;
   procedure Test_Ends_With;
   procedure Test_Prepend;
   procedure Test_Put_Image;
   procedure Test_Replace;
   procedure Test_Slice;
   procedure Test_Tail;
   procedure Test_To_Virtual_String_Vector;

   procedure Test_V705_011;
   --  Test that Slice implementation fills null terminator at the end of the
   --  internal string data.
   --
   --  This test requires valgrind.

   procedure Test_Ampersand_Character is separate;

   procedure Test_Asterisk_Character is separate;

   procedure Test_Delete_Pattern_Character is separate;

   procedure Test_Ends_With is separate;

   ------------------
   -- Test_Prepend --
   ------------------

   procedure Test_Prepend is
      Single : constant Wide_Wide_String := ".";
      Short  : constant Wide_Wide_String := "1234567890";
      Long   : constant Wide_Wide_String := "abcdefghijklmnopqrstuvwxyz";

      S     : VSS.Strings.Virtual_String;

   begin
      S.Prepend (VSS.Strings.To_Virtual_String (Single));
      Test_Support.Assert (S = VSS.Strings.To_Virtual_String (Single));

      S.Prepend (VSS.Strings.To_Virtual_String (Short));
      Test_Support.Assert
        (S = VSS.Strings.To_Virtual_String (Short & Single));

      S.Prepend (VSS.Strings.To_Virtual_String (Long));
      Test_Support.Assert
        (S = VSS.Strings.To_Virtual_String (Long & Short & Single));

      S.Clear;

      S.Prepend (VSS.Strings.To_Virtual_String (Long));
      Test_Support.Assert
        (S = VSS.Strings.To_Virtual_String (Long));

      S.Prepend (VSS.Strings.To_Virtual_String (Short));
      Test_Support.Assert
        (S = VSS.Strings.To_Virtual_String (Short & Long));

      S.Prepend (VSS.Strings.To_Virtual_String (Single));
      Test_Support.Assert
        (S = VSS.Strings.To_Virtual_String (Single & Short & Long));

      S.Clear;
      S.Prepend (' ');
      Test_Support.Assert (S = " ");

      S.Clear;
      S.Prepend (VSS.Strings.To_Virtual_String (Single));
      S.Prepend (' ');
      Test_Support.Assert (S = VSS.Strings.To_Virtual_String (' ' & Single));

      S.Clear;
      S.Prepend (VSS.Strings.To_Virtual_String (Short));
      S.Prepend (' ');
      Test_Support.Assert (S = VSS.Strings.To_Virtual_String (' ' & Short));

      S.Clear;
      S.Prepend (VSS.Strings.To_Virtual_String (Long));
      S.Prepend (' ');
      Test_Support.Assert (S = VSS.Strings.To_Virtual_String (' ' & Long));
   end Test_Prepend;

   procedure Test_Put_Image is separate;

   ------------------
   -- Test_Replace --
   ------------------

   procedure Test_Replace is
   begin
      declare
         S  : VSS.Strings.Virtual_String := "Hello, bad world!";
         J1 : VSS.Strings.Character_Iterators.Character_Iterator :=
           S.At_First_Character;
         J2 : VSS.Strings.Character_Iterators.Character_Iterator :=
           S.At_Last_Character;

      begin
         Test_Support.Assert (J1.Forward);
         Test_Support.Assert (J1.Forward);
         Test_Support.Assert (J1.Forward);
         Test_Support.Assert (J1.Forward);
         Test_Support.Assert (J1.Forward);
         Test_Support.Assert (J1.Forward);
         Test_Support.Assert (J1.Forward);

         Test_Support.Assert (J2.Backward);
         Test_Support.Assert (J2.Backward);
         Test_Support.Assert (J2.Backward);
         Test_Support.Assert (J2.Backward);
         Test_Support.Assert (J2.Backward);
         Test_Support.Assert (J2.Backward);
         Test_Support.Assert (J2.Backward);

         S.Replace (J1, J2, "good");

         Test_Support.Assert (S = "Hello, good world!");
      end;

      declare
         S  : VSS.Strings.Virtual_String := "x1z";
         J1 : VSS.Strings.Character_Iterators.Character_Iterator :=
           S.At_First_Character;
         J2 : VSS.Strings.Character_Iterators.Character_Iterator :=
           S.At_Last_Character;

      begin
         Test_Support.Assert (J1.Forward);
         Test_Support.Assert (J2.Backward);

         S.Replace (J1, J2, 'y');

         Test_Support.Assert (S = "xyz");
      end;
   end Test_Replace;

   ----------------
   -- Test_Slice --
   ----------------

   procedure Test_Slice is separate;

   ---------------
   -- Test_Tail --
   ---------------

   procedure Test_Tail is
      S  : constant VSS.Strings.Virtual_String := "abcdefg";
      --  JF : VSS.Strings.Character_Iterators.Character_Iterator :=
      --    S.At_First_Character;
      --  JL : VSS.Strings.Character_Iterators.Character_Iterator :=
      --    S.At_Last_Character;
      JC : VSS.Strings.Character_Iterators.Character_Iterator :=
        S.At_First_Character;

   begin
      --  Move iterator to the character inside the string.

      Test_Support.Assert (JC.Forward);
      Test_Support.Assert (JC.Forward);
      Test_Support.Assert (JC.Forward);

      Test_Support.Assert (S.Tail_From (JC) = "defg");
      Test_Support.Assert (S.Tail_After (JC) = "efg");

      --  Corner cases.

      Test_Support.Assert (S.Tail_From (S.At_First_Character) = "abcdefg");
      Test_Support.Assert (S.Tail_After (S.At_First_Character) = "bcdefg");

      Test_Support.Assert (S.Tail_From (S.At_Last_Character) = "g");
      Test_Support.Assert (S.Tail_After (S.At_Last_Character).Is_Empty);
   end Test_Tail;

   -----------------------------------
   -- Test_To_Virtual_String_Vector --
   -----------------------------------

   procedure Test_To_Virtual_String_Vector is
      S : constant VSS.Strings.Virtual_String := "a";
      R : VSS.String_Vectors.Virtual_String_Vector;

   begin
      R := S.To_Virtual_String_Vector;
      Test_Support.Assert (not R.Is_Empty);
      Test_Support.Assert (R.Length = 1);
      Test_Support.Assert (R (1) = S);
   end Test_To_Virtual_String_Vector;

   -------------------
   -- Test_V705_011 --
   -------------------

   procedure Test_V705_011 is
      V1 : constant VSS.Strings.Virtual_String := "First string";
      V2 : constant VSS.Strings.Virtual_String :=
        VSS.Strings.To_Virtual_String
          (" Second string in the list. It is long enough to can't be placed"
           & "inside the string object without memory allocation");
      J  : constant VSS.Strings.Character_Iterators.Character_Iterator :=
        V2.At_First_Character;
      V  : VSS.String_Vectors.Virtual_String_Vector;
      R  : VSS.Strings.Virtual_String with Unreferenced;
      --  This value is only necessary to build result object, thus to allow
      --  valgrind to detect use of uninitialized value.

   begin
      V.Append (V1);
      V.Append (V2.Tail_After (J));
      R := V.Join_Lines (VSS.Strings.LF);
   end Test_V705_011;

   -------------------------
   -- Test_Virtual_String --
   -------------------------

   procedure Test_Virtual_String is
   begin
      Test_Support.Run_Testcase
        (Test_Ampersand_Character'Access, "& Virtual_Character");
      Test_Support.Run_Testcase
        (Test_Asterisk_Character'Access, "Natural * Virtual_Character");
      Test_Support.Run_Testcase
        (Test_Delete_Pattern_Character'Access,
         "Delete Virtual_Character Pattern");
      Test_Support.Run_Testcase (Test_Ends_With'Access, "Ends_With");
      Test_Support.Run_Testcase (Test_Prepend'Access, "Prepend");
      Test_Support.Run_Testcase (Test_Put_Image'Access, "Put_Image");
      Test_Support.Run_Testcase (Test_Replace'Access, "Replace");
      Test_Support.Run_Testcase (Test_Slice'Access, "Slice");
      Test_Support.Run_Testcase (Test_Tail'Access, "Tail");
      Test_Support.Run_Testcase
        (Test_To_Virtual_String_Vector'Access, "To_Virtual_String_Vector");

      Test_Support.Run_Testcase (Test_V705_011'Access, "V705_011 TN");
   end Test_Virtual_String;

begin
   Test_Support.Run_Testsuite (Test_Virtual_String'Access, "Virtual_String");
end Test_String;
