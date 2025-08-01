import gdb
import gdb.printing
from gnatdbg.tagged import reinterpret_tagged

# Use the tag class if it is available.
if hasattr(gdb, "ValuePrinter"):
    base = gdb.ValuePrinter
else:
    base = object


class Virtual_String_Printer(base):
    def __init__(self, val):
        self._val = val

    def to_string(self):
        text_type = gdb.lookup_type(
            "vss.implementation.text_handlers.abstract_text_handler"
        )
        utf8_type = gdb.lookup_type(
            "vss.implementation.text_handlers.utf8.abstract_utf8_text"
        )
        utf8static_type = gdb.lookup_type(
            "vss.implementation.text_handlers.utf8.variable.static.static_utf8_handler"
        )
        utf8dynamic_type = gdb.lookup_type(
            "vss.implementation.text_handlers.utf8.variable.dynamic.dynamic_utf8_handler"
        )

        storage = self._val["data"]["storage"]

        if all(byte == 0 for byte in storage.bytes):
            # "null" string
            return ""

        text = reinterpret_tagged(storage.cast(text_type))

        # GDB 16.1 GNAT Pro 20250616w unable to lookup `size` component declared by the
        # parent tagged type. `u8text` is used to workaround.

        if text.type == utf8static_type:
            u8text = storage.cast(utf8_type)
            text = reinterpret_tagged(storage.cast(utf8_type))
            return text["storage"].lazy_string(encoding="utf-8", length=u8text["size"])

        elif text.type == utf8dynamic_type:
            u8text = storage.cast(utf8_type)
            text = reinterpret_tagged(storage.cast(utf8_type))
            data = text["pointer"].dereference()
            return data["storage"].lazy_string(encoding="utf-8", length=u8text["size"])

        else:
            raise TypeError("<UNKNOWN TYPE>")

    def display_hint(self):
        return "string"


class VSSPrinter(gdb.printing.PrettyPrinter):
    """Pretty-print VSS strings."""

    def __init__(self):
        super().__init__("VSS")

    def __call__(self, val):
        if str(val.type) == "vss.strings.virtual_string":
            return Virtual_String_Printer(val)


gdb.printing.register_pretty_printer(None, VSSPrinter())
