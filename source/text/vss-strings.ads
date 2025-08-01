--
--  Copyright (C) 2020-2025, AdaCore
--
--  SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
--

--  API to process string data as sequences of Unicode Code Points.

pragma Ada_2022;

private with Ada.Streams;
with Ada.Strings.Text_Buffers;

with VSS.Characters;
private with VSS.Implementation.Referrers;
private with VSS.Implementation.Strings;
limited with VSS.String_Vectors;
limited with VSS.Strings.Cursors.Iterators.Characters;
limited with VSS.Strings.Cursors.Iterators.Grapheme_Clusters;
limited with VSS.Strings.Cursors.Iterators.Lines;
limited with VSS.Strings.Cursors.Iterators.Words;
limited with VSS.Transformers;

package VSS.Strings is

   pragma Preelaborate;
   pragma Remote_Types;

   type Character_Count is range 0 .. 2 ** 30 - 1;
   subtype Character_Index is Character_Count range 1 .. Character_Count'Last;

   type Grapheme_Cluster_Count is range 0 .. 2 ** 30 - 1;
   subtype Grapheme_Cluster_Index is Grapheme_Cluster_Count
     range 1 .. Grapheme_Cluster_Count'Last;

   type Line_Count is new Natural;
   subtype Line_Index is Line_Count range 1 .. Line_Count'Last;

   type Display_Cell_Count is new Natural;
   subtype Display_Cell_Index is
     Display_Cell_Count range 1 .. Display_Cell_Count'Last;
   --  Count of fixed pitch font cells, like cells in terminal.
   --
   --  Emoji and wide east asian characters occupies two cells, width of some
   --  grapheme clusters depends from the context.

   type Column_Count is new Grapheme_Cluster_Count;
   subtype Column_Index is Column_Count range 1 .. Column_Count'Last;

   type Hash_Type is mod 2**64;

   type Line_Terminator is (CR, LF, CRLF, NEL, VT, FF, LS, PS);

   type Line_Terminator_Set is array (Line_Terminator) of Boolean
     with Pack, Default_Component_Value => False;

   New_Line_Function : constant Line_Terminator_Set :=
     [CR | LF | CRLF | NEL => True, others => False];

   type Virtual_String is tagged private
     with String_Literal => To_Virtual_String,
          Put_Image => Put_Image;
   pragma Preelaborable_Initialization (Virtual_String);

   Empty_Virtual_String : constant Virtual_String;

   function Is_Empty (Self : Virtual_String'Class) return Boolean;
   --  Return True when string is empty string: it is ether null or has zero
   --  length.

   function Is_Null (Self : Virtual_String'Class) return Boolean;
   --  Return True when string is null.

   function Hash (Self : Virtual_String'Class) return Hash_Type;
   --  Return hash value for the given string.

   function Character_Length
     (Self : Virtual_String'Class) return Character_Count;
   --  Return number of characters.

   function Before_First_Character
     (Self : Virtual_String'Class)
      return VSS.Strings.Cursors.Iterators.Characters.Character_Iterator;
   --  Return iterator pointing before the first character of the string.

   function At_First_Character
     (Self : Virtual_String'Class)
      return VSS.Strings.Cursors.Iterators.Characters.Character_Iterator;
   --  Return iterator pointing to the first character of the string.

   function At_Character
     (Self     : Virtual_String'Class;
      Position : VSS.Strings.Cursors.Abstract_Character_Cursor'Class)
      return VSS.Strings.Cursors.Iterators.Characters.Character_Iterator;
   --  Return iterator pointing to the character at given position. Cursor
   --  must belong to the same string.

   function At_Last_Character
     (Self : Virtual_String'Class)
      return VSS.Strings.Cursors.Iterators.Characters.Character_Iterator;
   --  Return iterator pointing to the last character of the string.

   function After_Last_Character
     (Self : Virtual_String'Class)
      return VSS.Strings.Cursors.Iterators.Characters.Character_Iterator;
   --  Return iterator pointing after the last character of the string.

   function Before_First_Grapheme_Cluster
     (Self : Virtual_String'Class)
      return VSS.Strings.Cursors.Iterators.Grapheme_Clusters
               .Grapheme_Cluster_Iterator;
   --  Return iterator pointing before the first grapheme cluster of the
   --  string.

   function At_First_Grapheme_Cluster
     (Self : Virtual_String'Class)
      return VSS.Strings.Cursors.Iterators.Grapheme_Clusters
               .Grapheme_Cluster_Iterator;
   --  Return iterator pointing to the first grapheme cluster of the string.

   function At_Last_Grapheme_Cluster
     (Self : Virtual_String'Class)
      return VSS.Strings.Cursors.Iterators.Grapheme_Clusters
               .Grapheme_Cluster_Iterator;
   --  Return iterator pointing to the last grapheme cluster of the string.

   function At_Grapheme_Cluster
     (Self     : Virtual_String'Class;
      Position : VSS.Strings.Cursors.Abstract_Character_Cursor'Class)
      return VSS.Strings.Cursors.Iterators.Grapheme_Clusters
               .Grapheme_Cluster_Iterator;
   --  Return iterator pointing to the grapheme cluster of the string at the
   --  given position.

   function After_Last_Grapheme_Cluster
     (Self : Virtual_String'Class)
      return VSS.Strings.Cursors.Iterators.Grapheme_Clusters
               .Grapheme_Cluster_Iterator;
   --  Return iterator pointing after the last grapheme cluster of the string.

   function Before_First_Word
     (Self : Virtual_String'Class)
      return VSS.Strings.Cursors.Iterators.Words.Word_Iterator;
   --  Return iterator pointing before the first word of the string.

   function At_First_Word
     (Self : Virtual_String'Class)
      return VSS.Strings.Cursors.Iterators.Words.Word_Iterator;
   --  Return iterator pointing to the first word of the string.

   function At_Word
     (Self     : Virtual_String'Class;
      Position : VSS.Strings.Cursors.Abstract_Character_Cursor'Class)
      return VSS.Strings.Cursors.Iterators.Words.Word_Iterator;
   --  Return iterator pointing to the word of the string at the given
   --  position.

   function At_Last_Word
     (Self : Virtual_String'Class)
      return VSS.Strings.Cursors.Iterators.Words.Word_Iterator;
   --  Return iterator pointing to the last word of the string.

   function After_Last_Word
     (Self : Virtual_String'Class)
      return VSS.Strings.Cursors.Iterators.Words.Word_Iterator;
   --  Return iterator pointing after the last word of the string.

   function At_First_Line
     (Self            : Virtual_String'Class;
      Terminators     : Line_Terminator_Set := New_Line_Function;
      Keep_Terminator : Boolean := False)
      return VSS.Strings.Cursors.Iterators.Lines.Line_Iterator;
   --  Return iterator pointing to the first logical line of the string.

   function At_Line
     (Self            : Virtual_String'Class;
      Position        : VSS.Strings.Cursors.Abstract_Character_Cursor'Class;
      Terminators     : Line_Terminator_Set := New_Line_Function;
      Keep_Terminator : Boolean := False)
      return VSS.Strings.Cursors.Iterators.Lines.Line_Iterator;
   --  Return iterator pointing to the line at given position.

   function At_Last_Line
     (Self            : Virtual_String'Class;
      Terminators     : Line_Terminator_Set := New_Line_Function;
      Keep_Terminator : Boolean := False)
      return VSS.Strings.Cursors.Iterators.Lines.Line_Iterator;
   --  Return iterator pointing to the last logincs line of the string. Last
   --  logical line is a text before the last line terminator sequence when it
   --  ends text, or a text after last line terminator sequence when it is not
   --  ends text.

   overriding function "="
     (Left  : Virtual_String;
      Right : Virtual_String) return Boolean;
   function "<"
     (Left  : Virtual_String;
      Right : Virtual_String) return Boolean;
   function "<="
     (Left  : Virtual_String;
      Right : Virtual_String) return Boolean;
   function ">"
     (Left  : Virtual_String;
      Right : Virtual_String) return Boolean;
   function ">="
     (Left  : Virtual_String;
      Right : Virtual_String) return Boolean;
   --  Compare two strings in binary order of code points.

   function "&"
     (Left  : Virtual_String;
      Right : Virtual_String) return Virtual_String;
   function "&"
     (Left  : Virtual_String;
      Right : VSS.Characters.Virtual_Character) return Virtual_String;
   function "&"
     (Left  : VSS.Characters.Virtual_Character;
      Right : Virtual_String) return Virtual_String;
   --  Concatenation operator for virtual string and virtual characters.

   function "*"
     (Left  : Character_Count;
      Right : VSS.Characters.Virtual_Character) return Virtual_String;
   --  Create string by repeating given number of given character.

   function "*"
     (Left  : Natural;
      Right : Virtual_String) return VSS.String_Vectors.Virtual_String_Vector;
   --  Returns vector with given number of given string.

   procedure Clear (Self : in out Virtual_String'Class);
   --  Remove all data.

   procedure Append
     (Self : in out Virtual_String'Class;
      Item : VSS.Characters.Virtual_Character);
   --  Append given abstract character to the end of the string.

   procedure Append
     (Self : in out Virtual_String'Class;
      Item : Virtual_String'Class);
   --  Append another string to the end of the string.

   --  function Append
   --    (Self : Virtual_String'Class;
   --     Item : VSS.Characters.Virtual_Character) return Virtual_String;
   --  --  Append given abstract character to the end of the string and returns
   --  --  result.
   --
   --  procedure Append
   --    (Self : in out Virtual_String'Class;
   --     Item : Virtual_String'Class);
   --  --  Append given string to the end of the string.
   --
   --  function Append
   --    (Self : Virtual_String'Class;
   --     Item : Virtual_String'Class) return Virtual_String;
   --  --  Append given string to the end of the string and returns result.

   procedure Prepend
     (Self : in out Virtual_String'Class;
      Item : VSS.Characters.Virtual_Character);
   --  Prepend given character to the begin of the string.

   procedure Prepend
     (Self : in out Virtual_String'Class;
      Item : Virtual_String'Class);
   --  Prepend given string to the begin of the string.

   procedure Insert
     (Self     : in out Virtual_String'Class;
      Position : VSS.Strings.Cursors.Abstract_Cursor'Class;
      Item     : VSS.Characters.Virtual_Character);
   procedure Insert
     (Self     : in out Virtual_String'Class;
      Position : VSS.Strings.Cursors.Abstract_Cursor'Class;
      Item     : Virtual_String'Class);
   --  Inserts given item at the given position. Do nothing if the given
   --  position is invalid.

   --  function Insert
   --    (Self     : Virtual_String'Class;
   --     Position : VSS.Strings.Cursors.Abstract_Cursor'Class;
   --     Item     : VSS.Characters.Virtual_Character) return Virtual_String;
   --  function Insert
   --    (Self     : Virtual_String'Class;
   --     Position : VSS.Strings.Cursors.Abstract_Cursor'Class;
   --     Item     : Virtual_String'Class) return Virtual_String;
   --  --  Inserts given item at the given position and returns result. Returns
   --  --  source string if the given position is invalid.

   procedure Delete
     (Self : in out Virtual_String'Class;
      From : VSS.Strings.Cursors.Abstract_Cursor'Class;
      To   : VSS.Strings.Cursors.Abstract_Cursor'Class);
   --  procedure Remove
   --    (Self    : in out Virtual_String'Class;
   --     From_To : VSS.Strings.Cursors.Abstract_Cursor'Class);
   --  Delete characters from of the string starting from given position
   --  to given position.

   --  function Remove
   --    (Self : Virtual_String'Class;
   --     From : VSS.Strings.Cursors.Abstract_Cursor'Class;
   --     To   : VSS.Strings.Cursors.Abstract_Cursor'Class)
   --     return Virtual_String;
   --  function Remove
   --    (Self    : Virtual_String'Class;
   --     From_To : VSS.Strings.Cursors.Abstract_Cursor'Class)
   --     return Virtual_String;
   --  --  Removes characters from of the string starting from given position
   --  --  to given position and returns result.

   function Delete
     (Self    : Virtual_String'Class;
      Pattern : VSS.Characters.Virtual_Character) return Virtual_String;
   --  Removes every occurrence of the given character in the string.

   procedure Replace
     (Self : in out Virtual_String'Class;
      From : VSS.Strings.Cursors.Abstract_Cursor'Class;
      To   : VSS.Strings.Cursors.Abstract_Cursor'Class;
      By   : VSS.Characters.Virtual_Character);
   --  procedure Replace
   --    (Self    : in out Virtual_String'Class;
   --     From_To : VSS.Strings.Cursors.Abstract_Cursor'Class;
   --     By      : VSS.Characters.Virtual_Character);
   procedure Replace
     (Self : in out Virtual_String'Class;
      From : VSS.Strings.Cursors.Abstract_Cursor'Class;
      To   : VSS.Strings.Cursors.Abstract_Cursor'Class;
      By   : Virtual_String'Class);
   --  procedure Replace
   --    (Self    : in out Virtual_String'Class;
   --     From_To : VSS.Strings.Cursors.Abstract_Cursor'Class;
   --     By      : Virtual_String'Class);
   --  Replace slice from and to given positions by given item.

   --  function Replace
   --    (Self : Virtual_String'Class;
   --     From : VSS.Strings.Cursors.Abstract_Cursor'Class;
   --     To   : VSS.Strings.Cursors.Abstract_Cursor'Class;
   --     By   : VSS.Characters.Virtual_Character) return Virtual_String;
   --  function Replace
   --    (Self    : Virtual_String'Class;
   --     From_To : VSS.Strings.Cursors.Abstract_Cursor'Class;
   --     By      : VSS.Characters.Virtual_Character) return Virtual_String;
   --  function Replace
   --    (Self : Virtual_String'Class;
   --     From : VSS.Strings.Cursors.Abstract_Cursor'Class;
   --     To   : VSS.Strings.Cursors.Abstract_Cursor'Class;
   --     By   : Virtual_String'Class) return Virtual_String;
   --  function Replace
   --    (Self    : Virtual_String'Class;
   --     From_To : VSS.Strings.Cursors.Abstract_Cursor'Class;
   --     By      : Virtual_String'Class) return Virtual_String;
   --  --  Replace slice from and to given positions by given item and returns
   --  --  result.

   function Slice
     (Self : Virtual_String'Class;
      From : VSS.Strings.Cursors.Abstract_Cursor'Class;
      To   : VSS.Strings.Cursors.Abstract_Cursor'Class)
      return Virtual_String;
   function Slice
     (Self    : Virtual_String'Class;
      Segment : VSS.Strings.Cursors.Abstract_Cursor'Class)
      return Virtual_String;
   --  Returns slice of the string. Return "null" string when one of cursors
   --  doesn't belong to given string or invalid cursors.

   function Head_Before
     (Self   : Virtual_String'Class;
      Before : VSS.Strings.Cursors.Abstract_Cursor'Class)
      return Virtual_String;
   --  Return head of the string before given position.

   function Tail_From
     (Self : Virtual_String'Class;
      From : VSS.Strings.Cursors.Abstract_Cursor'Class) return Virtual_String;
   --  Return tail of the string starting from the given position.

   function Tail_After
     (Self  : Virtual_String'Class;
      After : VSS.Strings.Cursors.Abstract_Cursor'Class) return Virtual_String;
   --  Return tail of the string starting from the first character after given
   --  position.

   function Starts_With
     (Self   : Virtual_String'Class;
      Prefix : Virtual_String'Class) return Boolean;
   --  Return True when Self starts with Prefix.

   function Starts_With
     (Self        : Virtual_String'Class;
      Prefix      : Virtual_String'Class;
      Transformer : VSS.Transformers.Abstract_Transformer'Class)
      return Boolean;
   --  Return True when Self starts with Prefix. Transformer defines
   --  transformation of both strings before compare.

   function Ends_With
     (Self   : Virtual_String'Class;
      Suffix : Virtual_String'Class) return Boolean;
   --  Return True when Self has given Suffix.

   function Ends_With
     (Self   : Virtual_String'Class;
      Suffix : VSS.Characters.Virtual_Character) return Boolean;
   --  Return True when Self has given Suffix.

   function Ends_With
     (Self : Virtual_String'Class; Suffix : Line_Terminator) return Boolean;
   --  Return True when Self has given Suffix.

   function Ends_With
     (Self   : Virtual_String'Class;
      Suffix : Line_Terminator_Set) return Boolean;
   --  Return True when Self has given Suffix.

   function To_Virtual_String (Item : Wide_Wide_String) return Virtual_String;
   --  Convert given string into virtual string.

   function Split
     (Self                : Virtual_String'Class;
      Separator           : VSS.Characters.Virtual_Character;
      Keep_Empty_Segments : Boolean := True)
      return VSS.String_Vectors.Virtual_String_Vector;
   --  Split the string into substrings where separator occurs and return list
   --  of those strings.

   function Split_Lines
     (Self            : Virtual_String'Class;
      Terminators     : Line_Terminator_Set := New_Line_Function;
      Keep_Terminator : Boolean := False)
      return VSS.String_Vectors.Virtual_String_Vector;

   procedure Put_Image
     (Buffer : in out Ada.Strings.Text_Buffers.Root_Buffer_Type'Class;
      Item   : Virtual_String);

   function Transform
     (Self        : Virtual_String'Class;
      Transformer : VSS.Transformers.Abstract_Transformer'Class)
      return Virtual_String;
   --  Transform given text using given text transformer.

   procedure Transform
     (Self        : in out Virtual_String'Class;
      Transformer : VSS.Transformers.Abstract_Transformer'Class);
   --  Transform given text using given text transformer.

   function To_Virtual_String_Vector
     (Self : Virtual_String'Class)
      return VSS.String_Vectors.Virtual_String_Vector;
   --  Create string vector with single item of given string.

private

   type Magic_String_Access is access all Virtual_String'Class;

   ------------------
   -- Magic_String --
   ------------------

   procedure Read
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Self   : out Virtual_String);
   procedure Write
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Self   : Virtual_String);

   type Virtual_String is
     new VSS.Implementation.Referrers.Magic_String_Base with record
      Data : aliased VSS.Implementation.Strings.String_Data;
   end record
     with Read      => Read,
          Write     => Write;

   overriding procedure Adjust (Self : in out Virtual_String);
   overriding procedure Finalize (Self : in out Virtual_String);

   Empty_Virtual_String : constant Virtual_String :=
     --  (Ada.Finalization.Controlled with
     (VSS.Implementation.Referrers.Magic_String_Base with Data => <>);

end VSS.Strings;
