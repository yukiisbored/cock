-- | Parser that parses cock
module Cock.Parser (parser) where

import Cock.Html (Html (HtmlLiteral, HtmlTag), HtmlAttribute)
import qualified Data.Text as T
import Text.Parsec
  ( alphaNum,
    anyChar,
    between,
    char,
    eof,
    many,
    many1,
    manyTill,
    option,
    sepBy,
    spaces,
    (<|>),
  )
import Text.Parsec.Indent (IndentParser, indented, withPos)

-- | Parser definition which uses Text as stream
type Parser a = IndentParser T.Text () a

-- | Definition for "identifier characters"
identifierChar :: Parser Char
identifierChar = alphaNum <|> char '-'

-- | Parse attribute
attribute :: Parser HtmlAttribute
attribute = do
  k <- manyTill identifierChar (char '=')
  v <- char '"' *> manyTill anyChar (char '"')

  return (T.pack k, T.pack v)

-- | Parse attributes
attributes :: Parser [HtmlAttribute]
attributes = between (char '[') (char ']') (sepBy attribute (char ' '))

-- | Parse literals
literal :: Parser Html
literal = do
  t <- char '"' *> manyTill anyChar (char '"')

  return $ HtmlLiteral (T.pack t)

-- | Parse tags
tag :: Parser Html
tag = withPos $ do
  name <- many1 identifierChar <* spaces
  attrs <- option [] attributes <* spaces
  child <- many $ indented *> html <* spaces

  return $ HtmlTag (T.pack name) attrs child

-- | Parse html
html :: Parser Html
html = tag <|> literal <* spaces

-- | Parse cock documents
parser :: Parser [Html]
parser = many html <* eof