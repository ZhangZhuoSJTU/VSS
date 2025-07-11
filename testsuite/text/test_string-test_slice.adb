--
--  Copyright (C) 2021-2025, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  Simple test for Virtual_String.Slice subprograms.
--
--  This test need to be enhanced to check corner cases and special conditions,
--  at least:
--   - invalid cursors
--   - misuse of cursor for another string

with VSS.Strings.Character_Iterators;
with VSS.Strings.Line_Iterators;

separate (Test_String)
procedure Test_Slice is
   S  : constant VSS.Strings.Virtual_String :=
     VSS.Strings.To_Virtual_String ("ASCII Кириллица ⊗∬ 𝛻𝜕 ");
   S1 : constant VSS.Strings.Virtual_String :=
     VSS.Strings.To_Virtual_String ("A");
   S2 : constant VSS.Strings.Virtual_String :=
     VSS.Strings.To_Virtual_String ("ASCII");
   S3 : constant VSS.Strings.Virtual_String :=
     VSS.Strings.To_Virtual_String ("Кириллица");
   S4 : constant VSS.Strings.Virtual_String :=
     VSS.Strings.To_Virtual_String ("⊗∬ 𝛻𝜕 ");

   J1 : VSS.Strings.Character_Iterators.Character_Iterator :=
     S.At_First_Character;
   J2 : VSS.Strings.Character_Iterators.Character_Iterator :=
     S.At_First_Character;
   D  : Boolean with Unreferenced;

begin
   Test_Support.Assert (S.Slice (J1, J2) = S1);
   Test_Support.Assert (S.Slice (J1) = S1);

   D := J2.Forward;
   D := J2.Forward;
   D := J2.Forward;
   D := J2.Forward;

   Test_Support.Assert (S.Slice (J2, J1).Is_Empty);
   Test_Support.Assert (S.Slice (J1, J2) = S2);

   D := J1.Forward;
   D := J1.Forward;
   D := J1.Forward;
   D := J1.Forward;
   D := J1.Forward;
   D := J1.Forward;

   D := J2.Forward;
   D := J2.Forward;
   D := J2.Forward;
   D := J2.Forward;
   D := J2.Forward;
   D := J2.Forward;
   D := J2.Forward;
   D := J2.Forward;
   D := J2.Forward;
   D := J2.Forward;

   Test_Support.Assert (S.Slice (J1, J2) = S3);

   D := J1.Forward;
   D := J1.Forward;
   D := J1.Forward;
   D := J1.Forward;
   D := J1.Forward;
   D := J1.Forward;
   D := J1.Forward;
   D := J1.Forward;
   D := J1.Forward;
   D := J1.Forward;

   D := J2.Forward;
   D := J2.Forward;
   D := J2.Forward;
   D := J2.Forward;
   D := J2.Forward;
   D := J2.Forward;
   D := J2.Forward;

   Test_Support.Assert (S.Slice (J1, J2) = S4);

   declare
      --  Check misuse of cursors for defferent string objects.

      S1 : constant VSS.Strings.Virtual_String := "This is some text";
      S2 : constant VSS.Strings.Virtual_String := "This is some text";

      JCV : VSS.Strings.Character_Iterators.Character_Iterator;
      JLV : VSS.Strings.Line_Iterators.Line_Iterator;
      JC1 : constant VSS.Strings.Character_Iterators.Character_Iterator :=
        S1.At_First_Character;
      JC2 : constant VSS.Strings.Character_Iterators.Character_Iterator :=
        S2.At_First_Character;
      JL1 : constant VSS.Strings.Line_Iterators.Line_Iterator           :=
        S1.At_First_Line;
      JL2 : constant VSS.Strings.Line_Iterators.Line_Iterator           :=
        S2.At_First_Line;

      R   : VSS.Strings.Virtual_String;

   begin
      R := S1.Slice (JC2);
      Test_Support.Assert (R.Is_Null);

      R := S1.Slice (JC2, JC1);
      Test_Support.Assert (R.Is_Null);

      R := S1.Slice (JC1, JC2);
      Test_Support.Assert (R.Is_Null);

      R := S1.Slice (JC2, JC2);
      Test_Support.Assert (R.Is_Null);

      R := S1.Slice (JCV);
      Test_Support.Assert (R.Is_Null);

      R := S1.Slice (JCV, JC1);
      Test_Support.Assert (R.Is_Null);

      R := S1.Slice (JC1, JCV);
      Test_Support.Assert (R.Is_Null);

      R := S1.Slice (JCV, JCV);
      Test_Support.Assert (R.Is_Null);

      R := S1.Slice (JL2);
      Test_Support.Assert (R.Is_Null);

      R := S1.Slice (JL2, JL1);
      Test_Support.Assert (R.Is_Null);

      R := S1.Slice (JL1, JL2);
      Test_Support.Assert (R.Is_Null);

      R := S1.Slice (JL2, JL2);
      Test_Support.Assert (R.Is_Null);

      R := S1.Slice (JLV);
      Test_Support.Assert (R.Is_Null);

      R := S1.Slice (JLV, JL1);
      Test_Support.Assert (R.Is_Null);

      R := S1.Slice (JL1, JLV);
      Test_Support.Assert (R.Is_Null);

      R := S1.Slice (JLV, JLV);
      Test_Support.Assert (R.Is_Null);
   end;

   --  Slice of string with last marker pointing to end of string.
   --
   --  It was reported under eng/ide/VSS#256

   declare
      use type VSS.Strings.Character_Count;

      SS : constant VSS.Strings.Virtual_String := "body ";
      --  Static storage
      SR : constant VSS.Strings.Virtual_String := "package body ";
      --  Reported case: static storage of max size on 64bit platform
      SD : constant VSS.Strings.Virtual_String := "package body Name ";
      --  Dynamic storage
      R  : VSS.Strings.Virtual_String;

   begin
      R := SS.Slice (SS.At_First_Character, SS.After_Last_Character);
      Test_Support.Assert (R.Character_Length = SS.Character_Length);
      Test_Support.Assert (R = SS);

      R := SR.Slice (SR.At_First_Character, SR.After_Last_Character);
      Test_Support.Assert (R.Character_Length = SR.Character_Length);
      Test_Support.Assert (R = SR);

      R := SD.Slice (SD.At_First_Character, SD.After_Last_Character);
      Test_Support.Assert (R.Character_Length = SD.Character_Length);
      Test_Support.Assert (R = SD);
   end;
end Test_Slice;
