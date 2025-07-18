--
--  Copyright (C) 2020-2025, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

with System.Storage_Elements;

with VSS.Implementation.UTF8_Encoding;

package body VSS.Implementation.Text_Handlers is

   use type VSS.Unicode.Code_Point;

   ------------
   -- Append --
   ------------

   procedure Append
     (Self   : in out Abstract_Text_Handler;
      Data   : in out VSS.Implementation.Strings.String_Data;
      Suffix : VSS.Implementation.Strings.String_Data;
      Offset : in out VSS.Implementation.Strings.Cursor_Offset)
   is
      Suffix_Handler : constant not null
        VSS.Implementation.Strings.Constant_Text_Handler_Access :=
          VSS.Implementation.Strings.Constant_Handler (Suffix);
      Position       : aliased VSS.Implementation.Strings.Cursor;
      Code           : VSS.Unicode.Code_Point;

   begin
      Suffix_Handler.Before_First_Character (Position);

      while Suffix_Handler.Forward (Position) loop
         Code := Suffix_Handler.Element (Position);
         Abstract_Text_Handler'Class (Self).Append (Code, Offset);
      end loop;
   end Append;

   ------------------
   -- Compute_Size --
   ------------------

   not overriding procedure Compute_Size
     (Self   : Abstract_Text_Handler;
      From   : VSS.Implementation.Strings.Cursor;
      To     : VSS.Implementation.Strings.Cursor;
      Size   : out VSS.Implementation.Strings.Cursor_Offset)
   is
      use type VSS.Unicode.UTF16_Code_Unit_Offset;
      use type VSS.Unicode.UTF8_Code_Unit_Offset;

      Text          : Abstract_Text_Handler'Class
        renames Abstract_Text_Handler'Class (Self);
      From_Position : aliased VSS.Implementation.Strings.Cursor;
      To_Position   : aliased VSS.Implementation.Strings.Cursor;
      Success       : Boolean with Unreferenced;

   begin
      if From.Index > To.Index then
         Size := (0, 0, 0);

      else
         if From.UTF8_Offset < 0 or From.UTF16_Offset < 0 then
            --  Some of UTF* offset of From must be resolved first.

            Text.Before_First_Character (From_Position);

            while From_Position.Index /= From.Index
              and then Text.Forward (From_Position)
            loop
               null;
            end loop;

         else
            From_Position := From;
         end if;

         if To.UTF8_Offset < 0 or To.UTF16_Offset < 0 then
            --  Some of UTF* offset of To must be resolved first.

            To_Position := From_Position;

            while To_Position.Index /= To.Index
              and then Text.Forward (To_Position)
            loop
               null;
            end loop;

         else
            To_Position := To;
         end if;

         Success := Text.Forward (To_Position);

         Size.Index_Offset := To_Position.Index - From_Position.Index;
         Size.UTF8_Offset  :=
           To_Position.UTF8_Offset - From_Position.UTF8_Offset;
         Size.UTF16_Offset :=
           To_Position.UTF16_Offset - From_Position.UTF16_Offset;
      end if;
   end Compute_Size;

   ---------------
   -- Ends_With --
   ---------------

   not overriding function Ends_With
     (Self   : Abstract_Text_Handler;
      Suffix : Abstract_Text_Handler'Class) return Boolean
   is
      Text            : Abstract_Text_Handler'Class
        renames Abstract_Text_Handler'Class (Self);
      Position        : VSS.Implementation.Strings.Cursor;
      Suffix_Position : VSS.Implementation.Strings.Cursor;

   begin
      Text.After_Last_Character (Position);
      Suffix.After_Last_Character (Suffix_Position);

      while
        Text.Backward (Position)
          and Suffix.Backward (Suffix_Position)
      loop
         if Text.Element (Position) /= Suffix.Element (Suffix_Position) then
            return False;
         end if;
      end loop;

      return True;
   end Ends_With;

   ------------------------
   -- First_UTF16_Offset --
   ------------------------

   not overriding function First_UTF16_Offset
     (Self     : Abstract_Text_Handler;
      Position : VSS.Implementation.Strings.Cursor)
      return VSS.Unicode.UTF16_Code_Unit_Index
   is
      use type VSS.Unicode.UTF16_Code_Unit_Offset;

      Text : Abstract_Text_Handler'Class
        renames Abstract_Text_Handler'Class (Self);
      Aux  : aliased VSS.Implementation.Strings.Cursor;

   begin
      if Position.UTF16_Offset >= 0 then
         return Position.UTF16_Offset;

      else
         Text.Before_First_Character (Aux);

         while Aux.Index /= Position.Index
           and then Text.Forward (Aux)
         loop
            null;
         end loop;
      end if;

      return Aux.UTF16_Offset;
   end First_UTF16_Offset;

   -----------------------
   -- First_UTF8_Offset --
   -----------------------

   not overriding function First_UTF8_Offset
     (Self     : Abstract_Text_Handler;
      Position : VSS.Implementation.Strings.Cursor)
      return VSS.Unicode.UTF8_Code_Unit_Index
   is
      use type VSS.Unicode.UTF8_Code_Unit_Offset;

      Text : Abstract_Text_Handler'Class
        renames Abstract_Text_Handler'Class (Self);
      Aux  : aliased VSS.Implementation.Strings.Cursor;

   begin
      if Position.UTF8_Offset >= 0 then
         return Position.UTF8_Offset;

      else
         Text.Before_First_Character (Aux);

         while Aux.Index /= Position.Index
           and then Text.Forward (Aux)
         loop
            null;
         end loop;
      end if;

      return Aux.UTF8_Offset;
   end First_UTF8_Offset;

   ---------------------
   -- Forward_Element --
   ---------------------

   not overriding function Forward_Element
     (Self     : Abstract_Text_Handler;
      Position : aliased in out VSS.Implementation.Strings.Cursor;
      Element  : out VSS.Unicode.Code_Point'Base) return Boolean is
   begin
      if Abstract_Text_Handler'Class (Self).Forward (Position) then
         Element := Abstract_Text_Handler'Class (Self).Element (Position);

         return True;

      else
         Element := VSS.Implementation.Strings.No_Character;

         return False;
      end if;
   end Forward_Element;

   -----------------------
   -- From_UTF_8_String --
   -----------------------

   not overriding procedure From_UTF_8_String
     (Self    : in out Abstract_Text_Handler;
      Item    : Ada.Strings.UTF_Encoding.UTF_8_String;
      Success : out Boolean)
   is
      use type VSS.Unicode.UTF8_Code_Unit_Offset;

      UTF8_Data  : constant
        VSS.Implementation.UTF8_Encoding.UTF8_Code_Unit_Array
          (0 .. VSS.Unicode.UTF8_Code_Unit_Offset (Item'Length - 1))
        with Import, Address => Item'Address;
      UTF8_Index : VSS.Unicode.UTF8_Code_Unit_Index := UTF8_Data'First;
      Code       : VSS.Unicode.Code_Point'Base;
      Error      : VSS.Implementation.UTF8_Encoding.UTF8_Decode_Error;
      Offset     : VSS.Implementation.Strings.Cursor_Offset;

   begin
      Success := True;

      loop
         exit when UTF8_Index > UTF8_Data'Last;

         VSS.Implementation.UTF8_Encoding.Decode
           (UTF8_Data, UTF8_Index, Code, Success, Error);

         exit when not Success;

         Abstract_Text_Handler'Class (Self).Append (Code, Offset);
      end loop;
   end From_UTF_8_String;

   ----------
   -- Hash --
   ----------

   not overriding procedure Hash
     (Self      : Abstract_Text_Handler;
      Generator : in out VSS.Implementation.FNV_Hash.FNV_1a_Generator)
   is
      Handler  : Abstract_Text_Handler'Class
        renames Abstract_Text_Handler'Class (Self);
      Position : aliased VSS.Implementation.Strings.Cursor;
      Code     : VSS.Unicode.Code_Point;

   begin
      Handler.Before_First_Character (Position);

      while Handler.Forward (Position) loop
         Code := Handler.Element (Position);

         VSS.Implementation.FNV_Hash.Hash
           (Generator,
            System.Storage_Elements.Storage_Element (Code and 16#0000_00FF#));
         Code := Code / 16#0000_0100#;
         VSS.Implementation.FNV_Hash.Hash
           (Generator,
            System.Storage_Elements.Storage_Element (Code and 16#0000_00FF#));
         Code := Code / 16#0000_0100#;
         VSS.Implementation.FNV_Hash.Hash
           (Generator,
            System.Storage_Elements.Storage_Element (Code and 16#0000_00FF#));
         Code := Code / 16#0000_0100#;
         VSS.Implementation.FNV_Hash.Hash
           (Generator,
            System.Storage_Elements.Storage_Element (Code and 16#0000_00FF#));
      end loop;
   end Hash;

   ------------
   -- Insert --
   ------------

   not overriding procedure Insert
     (Self   : in out Abstract_Text_Handler;
      From   : VSS.Implementation.Strings.Cursor;
      Item   : VSS.Implementation.Strings.String_Data;
      Offset : in out VSS.Implementation.Strings.Cursor_Offset)
   is
      Item_Handler  : constant not null
        VSS.Implementation.Strings.Constant_Text_Handler_Access :=
          VSS.Implementation.Strings.Constant_Handler (Item);
      Item_Position : aliased VSS.Implementation.Strings.Cursor;
      Position      : aliased VSS.Implementation.Strings.Cursor := From;
      Code          : VSS.Unicode.Code_Point;
      Success       : Boolean with Unreferenced;
      Text          :
        VSS.Implementation.Text_Handlers.Abstract_Text_Handler'Class
         renames VSS.Implementation.Text_Handlers.Abstract_Text_Handler'Class
           (Self);

   begin
      if Item_Handler.Is_Empty then
         return;
      end if;

      Item_Handler.Before_First_Character (Item_Position);

      while Item_Handler.Forward (Item_Position) loop
         Code := Item_Handler.Element (Item_Position);

         Text.Insert (Position, Code, Offset);
         Success := Text.Forward (Position);
      end loop;
   end Insert;

   --------------
   -- Is_Equal --
   --------------

   not overriding function Is_Equal
     (Self  : Abstract_Text_Handler;
      Other : Abstract_Text_Handler'Class) return Boolean
   is
      Left_Handler   : Abstract_Text_Handler'Class
        renames Abstract_Text_Handler'Class (Self);
      Right_Handler  : Abstract_Text_Handler'Class renames Other;

      Left_Position  : aliased VSS.Implementation.Strings.Cursor;
      Right_Position : aliased VSS.Implementation.Strings.Cursor;
      Left_Code      : VSS.Unicode.Code_Point;
      Right_Code     : VSS.Unicode.Code_Point;

   begin
      Left_Handler.Before_First_Character (Left_Position);
      Right_Handler.Before_First_Character (Right_Position);

      while
        Left_Handler.Forward (Left_Position)
          and Right_Handler.Forward (Right_Position)
      loop
         Left_Code  := Left_Handler.Element (Left_Position);
         Right_Code := Right_Handler.Element (Right_Position);

         if Left_Code /= Right_Code then
            return False;
         end if;
      end loop;

      return
        not Left_Handler.Has_Character (Left_Position)
          and not Right_Handler.Has_Character (Right_Position);
   end Is_Equal;

   -------------
   -- Is_Less --
   -------------

   not overriding function Is_Less
     (Self  : Abstract_Text_Handler;
      Other : Abstract_Text_Handler'Class) return Boolean
   is
      Left_Handler   : Abstract_Text_Handler'Class
        renames Abstract_Text_Handler'Class (Self);
      Right_Handler  : Abstract_Text_Handler'Class renames Other;

      Left_Position  : aliased VSS.Implementation.Strings.Cursor;
      Right_Position : aliased VSS.Implementation.Strings.Cursor;
      Left_Code      : VSS.Unicode.Code_Point;
      Right_Code     : VSS.Unicode.Code_Point;

   begin
      Left_Handler.Before_First_Character (Left_Position);
      Right_Handler.Before_First_Character (Right_Position);

      while
        Left_Handler.Forward (Left_Position)
          and Right_Handler.Forward (Right_Position)
      loop
         Left_Code  := Left_Handler.Element (Left_Position);
         Right_Code := Right_Handler.Element (Right_Position);

         if Left_Code /= Right_Code then
            return Left_Code < Right_Code;
         end if;
      end loop;

      return Right_Handler.Has_Character (Right_Position);
   end Is_Less;

   ----------------------
   -- Is_Less_Or_Equal --
   ----------------------

   not overriding function Is_Less_Or_Equal
     (Self  : Abstract_Text_Handler;
      Other : Abstract_Text_Handler'Class) return Boolean
   is
      Left_Handler   : Abstract_Text_Handler'Class
        renames Abstract_Text_Handler'Class (Self);
      Right_Handler  : Abstract_Text_Handler'Class renames Other;

      Left_Position  : aliased VSS.Implementation.Strings.Cursor;
      Right_Position : aliased VSS.Implementation.Strings.Cursor;
      Left_Code      : VSS.Unicode.Code_Point;
      Right_Code     : VSS.Unicode.Code_Point;

   begin
      Left_Handler.Before_First_Character (Left_Position);
      Right_Handler.Before_First_Character (Right_Position);

      while
        Left_Handler.Forward (Left_Position)
          and Right_Handler.Forward (Right_Position)
      loop
         Left_Code  := Left_Handler.Element (Left_Position);
         Right_Code := Right_Handler.Element (Right_Position);

         if Left_Code /= Right_Code then
            return Left_Code < Right_Code;
         end if;
      end loop;

      return
        Right_Handler.Has_Character (Right_Position)
          or not Left_Handler.Has_Character (Left_Position);
   end Is_Less_Or_Equal;

   -------------
   -- Is_Null --
   -------------

   not overriding function Is_Null
     (Self : Abstract_Text_Handler) return Boolean is (False);

   -----------------------
   -- Last_UTF16_Offset --
   -----------------------

   not overriding function Last_UTF16_Offset
     (Self     : Abstract_Text_Handler;
      Position : VSS.Implementation.Strings.Cursor)
      return VSS.Unicode.UTF16_Code_Unit_Index
   is
      use type VSS.Unicode.UTF16_Code_Unit_Offset;

      Text  : Abstract_Text_Handler'Class
        renames Abstract_Text_Handler'Class (Self);
      Aux   : aliased VSS.Implementation.Strings.Cursor;
      Dummy : Boolean;

   begin
      if Position.UTF16_Offset >= 0 then
         Aux := Position;

      else
         Text.Before_First_Character (Aux);

         while Aux.Index /= Position.Index
           and then Text.Forward (Aux)
         loop
            null;
         end loop;
      end if;

      Dummy := Text.Forward (Aux);

      return Aux.UTF16_Offset - 1;
   end Last_UTF16_Offset;

   ----------------------
   -- Last_UTF8_Offset --
   ----------------------

   not overriding function Last_UTF8_Offset
     (Self     : Abstract_Text_Handler;
      Position : VSS.Implementation.Strings.Cursor)
      return VSS.Unicode.UTF8_Code_Unit_Index
   is
      use type VSS.Unicode.UTF8_Code_Unit_Offset;

      Text  : Abstract_Text_Handler'Class
        renames Abstract_Text_Handler'Class (Self);
      Aux   : aliased VSS.Implementation.Strings.Cursor;
      Dummy : Boolean;

   begin
      if Position.UTF8_Offset >= 0 then
         Aux := Position;

      else
         Text.Before_First_Character (Aux);

         while Aux.Index /= Position.Index
           and then Text.Forward (Aux)
         loop
            null;
         end loop;
      end if;

      Dummy := Text.Forward (Aux);

      return Aux.UTF8_Offset - 1;
   end Last_UTF8_Offset;

   -----------
   -- Slice --
   -----------

   not overriding procedure Slice
     (Self   : Abstract_Text_Handler;
      From   : VSS.Implementation.Strings.Cursor;
      To     : VSS.Implementation.Strings.Cursor;
      Target : out VSS.Implementation.Strings.String_Data)
   is
      Source_Text : Abstract_Text_Handler'Class
        renames Abstract_Text_Handler'Class (Self);
      Current     : aliased VSS.Implementation.Strings.Cursor;
      Offset      : VSS.Implementation.Strings.Cursor_Offset := (0, 0, 0);
      Result_Text : constant not null
        VSS.Implementation.Strings.Variable_Text_Handler_Access :=
          VSS.Implementation.Strings.Variable_Handler (Target);

   begin
      if From.Index <= To.Index then
         Current := From;

         Result_Text.Append (Source_Text.Element (Current), Offset);

         while Source_Text.Forward (Current)
           and then Current.Index <= To.Index
         loop
            Result_Text.Append (Source_Text.Element (Current), Offset);
         end loop;
      end if;
   end Slice;

   -----------
   -- Split --
   -----------

   not overriding procedure Split
     (Self             : Abstract_Text_Handler;
      Data             : VSS.Implementation.Strings.String_Data;
      Separator        : VSS.Unicode.Code_Point;
      Keep_Empty_Parts : Boolean;
      Items            : in out
        VSS.Implementation.String_Vectors.String_Vector_Data_Access)
   is
      procedure Append;
      --  Append found substring to the results

      Handler  : Abstract_Text_Handler'Class
        renames Abstract_Text_Handler'Class (Self);
      Current  : aliased VSS.Implementation.Strings.Cursor;
      Previous : VSS.Implementation.Strings.Cursor;
      From     : aliased VSS.Implementation.Strings.Cursor;
      Success  : Boolean with Unreferenced;

      ------------
      -- Append --
      ------------

      procedure Append is
         Item : VSS.Implementation.Strings.String_Data;

      begin
         if Current.Index /= From.Index then
            Handler.Slice (From, Previous, Item);
            VSS.Implementation.String_Vectors.Append (Items, Item);
            VSS.Implementation.Strings.Unreference (Item);

         elsif Keep_Empty_Parts then
            VSS.Implementation.String_Vectors.Append
              (Items, VSS.Implementation.Strings.Null_String_Data);
         end if;
      end Append;

   begin
      Handler.Before_First_Character (From);
      Success := Handler.Forward (From);

      Handler.Before_First_Character (Current);
      Previous := Current;

      while Handler.Forward (Current) loop
         if Handler.Element (Current) = Separator then
            Append;

            From    := Current;
            Success := Handler.Forward (From);
         end if;

         Previous := Current;
      end loop;

      Append;
   end Split;

   -----------------
   -- Starts_With --
   -----------------

   not overriding function Starts_With
     (Self   : Abstract_Text_Handler;
      Prefix : Abstract_Text_Handler'Class) return Boolean
   is
      Text            : Abstract_Text_Handler'Class
        renames Abstract_Text_Handler'Class (Self);
      Position        : aliased VSS.Implementation.Strings.Cursor;
      Prefix_Position : aliased VSS.Implementation.Strings.Cursor;

   begin
      Text.Before_First_Character (Position);
      Prefix.Before_First_Character (Prefix_Position);

      while
        Text.Forward (Position)
          and Prefix.Forward (Prefix_Position)
      loop
         if Text.Element (Position) /= Prefix.Element (Prefix_Position) then
            return False;
         end if;
      end loop;

      return True;
   end Starts_With;

end VSS.Implementation.Text_Handlers;
