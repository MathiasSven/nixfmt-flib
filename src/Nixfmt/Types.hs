{-# LANGUAGE OverloadedStrings #-}

module Nixfmt.Types where

import           Prelude         hiding (String)

import           Data.Text       hiding (concat, map)
import           Data.Void
import           Text.Megaparsec (Parsec)

type Parser = Parsec Void Text

data Trivium
    = EmptyLine
    | LineComment     Text
    | BlockComment    [Text]
    deriving (Show)

type Trivia = [Trivium]

data Ann a
    = Ann a (Maybe Text) Trivia
    deriving (Show)

type Leaf = Ann Token

data StringPart
    = TextPart Text
    | Interpolation Leaf Expression Token
    deriving (Show)

data String
    = SimpleString Token [StringPart] Leaf
    | IndentedString Token [StringPart] Leaf
    | URIString (Ann Text)
    deriving (Show)

data SimpleSelector
    = IDSelector Leaf
    | InterpolSelector (Ann StringPart)
    | StringSelector String
    deriving (Show)

data Selector
    = Selector (Maybe Leaf) SimpleSelector (Maybe (Leaf, Term))
    deriving (Show)

data Binder
    = Inherit Leaf (Maybe Term) [Leaf] Leaf
    | Assignment [Selector] Leaf Expression Leaf
    | BinderTrivia Trivia
    deriving (Show)

data ListPart
    = ListItem Term
    | ListTrivia Trivia
    deriving (Show)

data Term
    = Token Leaf
    | String String
    | List Leaf [ListPart] Leaf
    | Set (Maybe Leaf) Leaf [Binder] Leaf
    | Selection Term [Selector]
    | Parenthesized Leaf Expression Leaf
    deriving (Show)

data ParamAttr
    = ParamAttr Leaf (Maybe (Leaf, Expression)) (Maybe Leaf)
    | ParamEllipsis Leaf
    deriving (Show)

data Parameter
    = IDParameter Leaf
    | SetParameter Leaf [ParamAttr] Leaf
    | ContextParameter Parameter Leaf Parameter
    deriving (Show)

data Expression
    = Term Term
    | With Leaf Expression Leaf Expression
    | Let Leaf [Binder] Leaf Expression
    | Assert Leaf Expression Leaf Expression
    | If Leaf Expression Leaf Expression Leaf Expression
    | Abstraction Parameter Leaf Expression

    | Application Expression Expression
    | Operation Expression Leaf Expression
    | MemberCheck Expression Leaf [Selector]
    | Negation Leaf Expression
    | Inversion Leaf Expression
    deriving (Show)

data File
    = File Leaf Expression
    deriving (Show)

data Token
    = Integer    Int
    | Identifier Text
    | Path       Text
    | EnvPath    Text

    | KAssert
    | KElse
    | KIf
    | KIn
    | KInherit
    | KLet
    | KOr
    | KRec
    | KThen
    | KWith

    | TBraceOpen
    | TBraceClose
    | TBrackOpen
    | TBrackClose
    | TInterOpen
    | TInterClose
    | TParenOpen
    | TParenClose

    | TAssign
    | TAt
    | TColon
    | TComma
    | TDot
    | TDoubleQuote
    | TDoubleSingleQuote
    | TEllipsis
    | TQuestion
    | TSemicolon

    | TConcat
    | TNegate
    | TUpdate

    | TPlus
    | TMinus
    | TMul
    | TDiv

    | TAnd
    | TOr
    | TEqual
    | TGreater
    | TGreaterEqual
    | TImplies
    | TLess
    | TLessEqual
    | TNot
    | TUnequal

    | SOF
    deriving (Eq, Show)


data Fixity
    = Prefix
    | InfixL
    | InfixN
    | InfixR
    | Postfix
    deriving (Show)

data Operator
    = Op Fixity Token
    | Apply
    deriving (Show)

-- | A list of lists of operators where lists that come first contain operators
-- that bind more strongly.
operators :: [[Operator]]
operators =
    [ [ Apply ]
    , [ Op Prefix TMinus ]
    , [ Op Postfix TQuestion ]
    , [ Op InfixR TConcat ]
    , [ Op InfixL TMul
      , Op InfixL TDiv ]
    , [ Op InfixL TPlus
      , Op InfixL TMinus ]
    , [ Op Prefix TNot ]
    , [ Op InfixR TUpdate ]
    , [ Op InfixN TLess
      , Op InfixN TGreater
      , Op InfixN TLessEqual
      , Op InfixN TGreaterEqual ]
    , [ Op InfixN TEqual
      , Op InfixN TUnequal ]
    , [ Op InfixL TAnd ]
    , [ Op InfixL TOr ]
    , [ Op InfixL TImplies ]
    ]

tokenText :: Token -> Text
tokenText (Identifier i)     = i
tokenText (Integer i)        = pack (show i)
tokenText (Path p)           = p
tokenText (EnvPath p)        = "<" <> p <> ">"

tokenText KAssert            = "assert"
tokenText KElse              = "else"
tokenText KIf                = "if"
tokenText KIn                = "in"
tokenText KInherit           = "inherit"
tokenText KLet               = "let"
tokenText KOr                = "or"
tokenText KRec               = "rec"
tokenText KThen              = "then"
tokenText KWith              = "with"

tokenText TBraceOpen         = "{"
tokenText TBraceClose        = "}"
tokenText TBrackOpen         = "["
tokenText TBrackClose        = "]"
tokenText TInterOpen         = "${"
tokenText TInterClose        = "}"
tokenText TParenOpen         = "("
tokenText TParenClose        = ")"

tokenText TAssign            = "="
tokenText TAt                = "@"
tokenText TColon             = ":"
tokenText TComma             = ","
tokenText TDot               = "."
tokenText TDoubleQuote       = "\""
tokenText TDoubleSingleQuote = "''"
tokenText TEllipsis          = "..."
tokenText TQuestion          = "?"
tokenText TSemicolon         = ";"

tokenText TPlus              = "+"
tokenText TMinus             = "-"
tokenText TMul               = "*"
tokenText TDiv               = "/"
tokenText TConcat            = "++"
tokenText TNegate            = "-"
tokenText TUpdate            = "//"

tokenText TAnd               = "&&"
tokenText TOr                = "||"
tokenText TEqual             = "=="
tokenText TGreater           = ">"
tokenText TGreaterEqual      = ">="
tokenText TImplies           = "->"
tokenText TLess              = "<"
tokenText TLessEqual         = "<="
tokenText TNot               = "!"
tokenText TUnequal           = "!="

tokenText SOF                = ""
