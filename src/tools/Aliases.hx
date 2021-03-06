package tools;
import haxe.extern.EitherType;
import js.lib.RegExp;

/**
 * ...
 * @author YellowAfterlife
 */
class Aliases { }

typedef Success = Bool;
/** Whether an error was found (true/false) */
typedef FoundError = Bool;
typedef ErrorText = String;

/** An absolute path, such as "C:/dir/file.ext" */
typedef FullPath = String;

/** A relative path, such as "dir/file.ext" */
typedef RelPath = String;

/** A string containing some GML code */
typedef GmlCode = String;

/** A valid identifier like "scr_some" */
typedef GmlName = String;

/** An offset in a string */
typedef StringPos = Int;

typedef EitherType3<A, B, C> = EitherType<EitherType<A, B>, C>;
typedef EitherType4<A, B, C, D> = EitherType<EitherType<EitherType<A, B>, C>, D>;
