# /// script
# requires-python = ">=3.13"
# dependencies = ["pydantic"]
# ///

from enum import Enum
from typing import Optional
from pydantic import BaseModel, Field
import sys


class PointerType(str, Enum):
    MUTABLE = "mutable"
    IMMUTABLE = "immutable"


class Base(BaseModel):
    name: str
    namespace: str = ""
    doc: str = ""
    extended: bool = False


class Constant(Base):
    value: str


class Typedef(Base):
    type: str


class EnumEntry(Base):
    value: Optional[int] = None


class Enum(Base):
    entries: list[EnumEntry | None] = Field(default_factory=list)


class BitflagEntry(Base):
    value: str | None = None
    value_combination: list[str] = Field(default_factory=list)


class Bitflag(Base):
    entries: list[BitflagEntry] = Field(default_factory=list)


class ParameterType(BaseModel):
    name: str | None = None
    namespace: str = ""
    doc: str = ""
    type: str
    passed_with_ownership: Optional[bool] = None
    pointer: Optional[PointerType] = None
    optional: bool = False
    default: Optional[str | bool | int] = None


class Callback(Base):
    style: str
    args: list[ParameterType] = Field(default_factory=list)


class Function(Base):
    returns: Optional[ParameterType] = None
    callback: Optional[str] = None
    args: list[ParameterType] = Field(default_factory=list)


class Struct(Base):
    type: str
    free_members: bool = False
    members: list[ParameterType] = Field(default_factory=list)
    extends: list[str] = Field(default_factory=list)


class Object(Base):
    methods: list[Function] = Field(default_factory=list)


class Yml(BaseModel):
    copyright: str
    name: str
    doc: str
    enum_prefix: int

    constants: list[Constant] = Field(default_factory=list)
    typedefs: list[Typedef] = Field(default_factory=list)
    enums: list[Enum] = Field(default_factory=list)
    bitflags: list[Bitflag] = Field(default_factory=list)
    structs: list[Struct] = Field(default_factory=list)
    callbacks: list[Callback] = Field(default_factory=list)
    functions: list[Function] = Field(default_factory=list)
    objects: list[Object] = Field(default_factory=list)

def main() -> None:
    file = sys.argv[1]
    with open(file) as f:
        Yml.model_validate_json(f.read())


if __name__ == "__main__":
    main()
