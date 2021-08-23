(** User Mathematica initialization file **)

$ActiveSideOfSelection = Neither;
$ShiftReturnMode = "CursorDoesntMove";

(* btw this is useful https://www.wolframcloud.com/obj/github-cloud/form/BadgeCreation
example: https://www.wolframcloud.com/obj/github-cloud/commits/a69e783425874f894be49712c7494f9e528fa206 
I got it from the MSE chat *)

(* This removes the pesky 'Wolfram Mathematica' directory that 
clutters my home directory. Solutions are discussed in this SE post
https://mathematica.stackexchange.com/questions/89369/prevent-10-2-from-creating-wolfram-mathematica-directory-on-linux?rq=1 *)
With[{dir = $UserDocumentsDirectory <> "/Wolfram Mathematica"},
  If[DirectoryQ[dir], DeleteDirectory[dir]]
];

(* Also maybe find a way to make a command that runs code cleanly on 
a already running kernel so it doesnt take a second or two of startup 
time *)

(* This makes my absolutely beautiful tabbing work now. Beuatifal *)
(* One problem though. This gets called even when running a wolframscript
from the command line (you can tell because any wolframscript execution
emits an error message complaining about a lack of front end). I need
to figure out how to make this code run only on start up of a front end
and not on startup of a kernel. Also perhaps I should move this code
into a package so it doesnt clutter my init.m file *)
SetOptions[SelectedNotebook[], 
 NotebookEventActions -> {{"KeyDown", "\t"} :> 
    KeyBindings`OnTab[]}]; 

(* Note: one can use this to figure out what kind of key a keypress is: 
SetOptions[EvaluationNotebook[], 
 NotebookEventActions -> {"KeyDown" :> 
    Print[FullForm@CurrentValue["EventKey"]]}]
This is taken from https://mathematica.stackexchange.com/questions/139704/how-to-detect-special-key-presses-in-a-notebook/167223
*)

(* The two styling functions I know of are
	ResourceFunction["DarkMode"][]
	ResourceFunction["DraculaTheme"][]
*)

(* Also it looks like there is a problem with Desurround in this case: 
	[][Normal]
Highlight from the brackets surrounding Normal (dont include the open close
pair upfront). Now do Ctrl + Shift + Backspace and you will see the l in 
Normal does not get included in the selection, the selection only goes from 
N to a. This is a bug *)

(* Also I just discovered Alt + e + b. It does alot of the work that my Ctrl 
+ Left/Right bindings do and could significantly speed them up. If only I 
had known about it before *)

(* This is the traceView2 definition from this amazing SE post https://mathematica.stackexchange.com/questions/29339/the-clearest-\
way-to-represent-mathematicas-evaluation-sequence *)
TraceView[expr_] := 
 Module[{steps = {}, stack = {}, pre, post, show, dynamic}, 
  pre[e_] := (stack = {steps, stack}; steps = {}); 
  post[e_, r_] := (steps = 
     First@stack~Join~{show[e, HoldForm[r], steps]}; 
    stack = stack[[2]]); SetAttributes[post, HoldAllComplete]; 
  show[e_, r_, steps_] := 
   Grid[steps /. {{} -> {{"Expr  ", 
         Row[{e, " ", 
           Style["inert", {Italic, Small}]}]}}, _ -> {{"Expr  ", 
         e}, {"Steps", 
         steps /. {{} -> Style["no definitions apply", Italic], _ :> 
            OpenerView[{Length@steps, 
              dynamic@Column[steps]}]}}, {"Result", r}}}, 
    Alignment -> Left, Frame -> All, 
    Background -> {{LightCyan}, None}]; 
  TraceScan[pre, expr, ___, post]; 
  Deploy@Pane[steps[[1]] /. dynamic -> Dynamic, ImageSize -> 10000]];
SetAttributes[TraceView, {HoldAllComplete}];

(* One could write an ugly and simple function to convert a box structure to a 
simple string of characters with no special formatting. To be used 
for simple things like getting the first and last characters of a box 
expression or seeing what characters are in a box expression. I think 
for my purposes though this is unneccessary and simply these two 
functions will do. *)

(* Gets the first character of a box structure, if the first thing is 
not a character, returns None *)
KeyBindings`FirstCharacter[string_String] := First@Characters@string;
KeyBindings`FirstCharacter[RowBox[{first_, ___}]] := 
  KeyBindings`FirstCharacter@first;
KeyBindings`FirstCharacter[_] := None;

(* Gets the last character of a box structure, if the last thing is 
not a character, returns None *)
KeyBindings`LastCharacter[string_String] := Last@Characters@string;
KeyBindings`LastCharacter[RowBox[{___, last_}]] := 
  KeyBindings`LastCharacter@last;
KeyBindings`LastCharacter[_] := None;

(* When given a box structure, tells you how many times you would need 
to press Shift + Right to highlight it from right to left *)
KeyBindings`GetRightLength[RowBox[expr_]] := Plus @@ KeyBindings`GetRightLength /@ expr;
KeyBindings`GetRightLength[SuperscriptBox[expr_, _]] := 1 + KeyBindings`GetRightLength @ expr;
KeyBindings`GetRightLength[SubscriptBox[expr_, _]] := 1 + KeyBindings`GetRightLength @ expr;
KeyBindings`GetRightLength[s_String] := StringLength @ s;
KeyBindings`GetRightLength[_] := 1;

(* When given a box structure, tells you how many times you would need 
to press Shift + Left to highlight it from left to right *)
KeyBindings`GetLeftLength[RowBox[expr_]] := Plus @@ KeyBindings`GetLeftLength /@ expr;
KeyBindings`GetLeftLength[s_String] := StringLength @ s;
KeyBindings`GetLeftLength[_] := 1;

(* I need to implement all of these *)
(*
(* These next two would swap the selection with either its right or
left neighbor argument if they are both arguments of the same function *)
KeyBindings`SwapSelectionRight[] := 
KeyBindings`SwapSelectionLeft[] := 
*)

KeyBindings`ToggleShiftReturnMode[] := (
	$ShiftReturnMode = Switch[$ShiftReturnMode,
		"CursorDoesntMove",
		"CursorMovesBelowCell",
		"CursorDoesntMove",
		"CursorMovesBelowCell",
		_,
		"CursorDoesntMove"
	]
);

KeyBindings`OnShiftReturn[] := (
	Module[{nb, cell, selection, position},
	 nb = SelectedNotebook[];
	 (* If the selection is not in a cell then default to standard behavior *)
	 selection = FrontEndExecute@FrontEnd`UndocumentedGetSelectionPacket[nb];
	 If[Lookup[selection, "CellSelectionType"] =!= "ContentSelection", 
	  FrontEndExecute@FrontEndToken[nb, "HandleShiftReturn"],
	  Switch[$ShiftReturnMode,
	   "CursorDoesntMove",
	   cell = First@SelectedCells[nb];
	   position = Lookup[selection, "CharacterRange"];
	   FrontEndExecute@FrontEndToken[nb, "HandleShiftReturn"];
	   SelectionMove[cell, Before, CellContents];
	   SelectionMove[nb, Next, Character, position[[1]]];
	   SelectionMove[nb, All, Character, position[[2]] - position[[1]]],
	   "CursorMovesBelowCell",
	   FrontEndExecute@FrontEndToken[nb, "HandleShiftReturn"]
	   ]
	  ]
	 ]
);

(* This is supposed to reset the active side of the selection. This 
doesn't really work the way I want it to. I don't know how to do this *)
KeyBindings`ResetSelection[] := (
	(* Ill toss this line in here for testing *)
	$ActiveSideOfSelection = $ActiveSideOfSelection /. {Left -> Right, Right -> Left};
	Module[{nb},
		nb = SelectedNotebook[];
		FrontEndExecute @ FrontEndToken[nb, "CreateInlineCell"];
		FrontEndExecute @ FrontEndToken[nb, "ExpandSelection"];
		NotebookWrite[nb, NotebookRead[nb], All]
	]
);

(* If the selection is a list (or comma delimited) then this prints 
the individual components each on a newline *)
KeyBindings`Column[] := (
	Scan[text \[Function] NotebookWrite[#, If[text === ",", "\n", text]],
	   Module[{read = NotebookRead[#]}, 
	    If[MatchQ[read, 
	      RowBox[{"[", _RowBox, "]"}] | RowBox[{"{", _RowBox, "}"}]], 
	     read[[1, 2, 1]], read[[1]]]]
	   ] & @ SelectedNotebook[];
);

KeyBindings`ColumnRecursive[] := 
 Module[{nb, count, selection},
  nb = SelectedNotebook[];
  count = 0;
  selection = NotebookRead @ nb;
  If[KeyBindings`FirstCharacter @ selection === "{" && 
    KeyBindings`LastCharacter @ selection === "}",
   Scan[text \[Function] 
     NotebookWrite[nb, If[text === ",", count++; "\n", text]], 
    selection[[1, 2, 1]]];
   (* Print@count; *)
   Table[FrontEndExecute @ FrontEndToken[nb, "MovePreviousLine"], count];
   Table[
    FrontEndExecute @ FrontEndToken[nb, "MoveLineEnd"];
    FrontEndExecute @ FrontEndToken[nb, "SelectLineBeginning"];
    KeyBindings`ColumnRecursive[];
    FrontEndExecute @ FrontEndToken[nb, "MoveNextLine"],
    count + 1];
   FrontEndExecute @ FrontEndToken[nb, "MovePreviousLine"];
   FrontEndExecute @ FrontEndToken[nb, "MoveLineEnd"]
   (* , Print@"NO" *)
   ]
  ]

(* When the selection is a List or just comma delimited (no brackets
needed) then this reverses the selection *)
KeyBindings`Reverse[] := (
	NotebookWrite[#, Module[{text = NotebookRead[#]},
    If[MatchQ[text, 
    		RowBox[{"[", _RowBox, "]"}] | 
    		RowBox[{"{", _RowBox, "}"}]], 
     	MapAt[Reverse, text, {1, 2, 1}], 
     	Reverse /@ text]], All] & @ SelectedNotebook[];
);

(* Reload MenuSetup.tr and executes init.m. I don't know what 
FrontEnd`FlushTextResourceCaches does. It doesn't reload KeyEventTranslations.tr
unfortunately so its not as useful as it could be *)
KeyBindings`ReloadResources[] := (
	FrontEndExecute @ {FrontEnd`FlushTextResourceCaches[], 
	  ResetMenusPacket[{Automatic, Automatic}]};
	Get["/home/tanner/.Mathematica/Kernel/init.m"];
);

KeyBindings`OnOpenBracket[] := (
	Module[{type, range},
	 {type, range} = {"CellSelectionType", "CharacterRange"} /. 
	   FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[SelectedNotebook[]];
	 If[type === "ContentSelection" && range[[1]] =!= range[[2]],
	  NotebookApply[SelectedNotebook[], "[\[SelectionPlaceholder]]", All],
	  NotebookWrite[SelectedNotebook[], "["]]
	 ];
);

KeyBindings`OnOpenBrace[] := (
	Module[{type, range},
	 {type, range} = {"CellSelectionType", "CharacterRange"} /. 
	   FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[SelectedNotebook[]];
	 If[type === "ContentSelection" && range[[1]] =!= range[[2]],
	  NotebookApply[SelectedNotebook[], "{\[SelectionPlaceholder]}", All],
	  NotebookWrite[SelectedNotebook[], "{"]]
	 ];
);

KeyBindings`OnOpenParenthese[] := (
	Module[{type, range},
	 {type, range} = {"CellSelectionType", "CharacterRange"} /. 
	   FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[SelectedNotebook[]];
	 If[type === "ContentSelection" && range[[1]] =!= range[[2]],
	  NotebookApply[SelectedNotebook[], "(\[SelectionPlaceholder])", All],
	  NotebookWrite[SelectedNotebook[], "("]]
	 ];
);

KeyBindings`OnQuotation[] := (
	Module[{type, range},
	 {type, range} = {"CellSelectionType", "CharacterRange"} /. 
	   FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[SelectedNotebook[]];
	 If[type === "ContentSelection" && range[[1]] =!= range[[2]],
	  NotebookApply[SelectedNotebook[], "\"\[SelectionPlaceholder]\"", All],
	  NotebookWrite[SelectedNotebook[], "\""]]
	 ];
);

KeyBindings`OnLessThan[] := (
	Module[{type, range},
	 {type, range} = {"CellSelectionType", "CharacterRange"} /. 
	   FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[SelectedNotebook[]];
	 If[type === "ContentSelection" && range[[1]] =!= range[[2]],
	  NotebookApply[SelectedNotebook[], "\[LeftAssociation]\[SelectionPlaceholder]\[RightAssociation]", All],
	  NotebookWrite[SelectedNotebook[], "<"]]
	 ];
);

(* This currently doesn't work if the cursor is at the beginning or 
end of the cell *)
(* Its complicated because it tries hard to figure out if the cursor
is in or on the edge of a valid word so that it "does the right thing" *)
KeyBindings`OpenCurrentTextInDocumentation[] := (
Module[{nb, selection, left, right},
 nb = SelectedNotebook[];
 selection = 
  FrontEndExecute@FrontEnd`UndocumentedGetSelectionPacket[nb];
 (* If there is a selection then simulate a left arrow to set the \
cursor to the beginning of the selection *)
 
 If[Not@(Equal @@ Lookup[selection, "CharacterRange"]),
  FrontEndExecute@FrontEndToken[nb, "MovePrevious"]];
 (* Get character to left of cursor *)
 
 FrontEndExecute@FrontEndToken[nb, "SelectPrevious"];
 left = NotebookRead[nb];
 FrontEndExecute@FrontEndToken[nb, "MoveNext"];
 (* Get character to right of cursor *)
 
 FrontEndExecute@FrontEndToken[nb, "SelectNext"];
 right = NotebookRead[nb];
 FrontEndExecute@FrontEndToken[nb, "MovePrevious"];
 (* Determine if we are to the left to the right or in the middle of \
a word and act accordingly *)
 Which[
  StringMatchQ[left, Except[WordCharacter]] && 
   StringMatchQ[right, LetterCharacter],
  FrontEndExecute@FrontEndToken[nb, "SelectNextWord"],
  StringMatchQ[left, WordCharacter] && 
   StringMatchQ[right, Except[WordCharacter]],
  FrontEndExecute@FrontEndToken[nb, "SelectPreviousWord"],
  StringMatchQ[left, WordCharacter] && 
   StringMatchQ[right, WordCharacter],
  FrontEndExecute@FrontEndToken[nb, "ExpandSelection"],
  True,
  (* If we get here then we are between two nonalphanumeric \
characters and we should do nothing *)
  Null
  ];
 selection = NotebookRead[nb];
 (* If we didnt highlight anything or if the thing we highlighted \
isnt a valid function then do nothing. Otherwise look it up in the \
documentation *)
 If[selection === {} || Names[selection] === {},
  Null,
  NotebookOpen@
   FindFile@
    FileNameJoin@{"ReferencePages", "Symbols", selection <> ".nb"}
  ]
 ]
);

(* This could be improved. Right now it does not work in text cells 
because they handle the front end token "Tab" differently. Maybe put
a check in to see if we are in a text cell and if so not call the 
token. This should work because typesetting in text cells isnt 
possible (if you try it actually creates an inline cell where the 
typsetting is possible) *)
KeyBindings`OnTab[] := Module[{nb, type, range}, 
	nb = SelectedNotebook[];
	{type, range} = {"CellSelectionType", "CharacterRange"} /. FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[nb];
	If[type === "ContentSelection",
		FrontEndExecute @ FrontEndToken[nb, "Tab"];
		If[range === ("CharacterRange" /. FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[nb]),
			(* If hitting tab does nothing then its not for navigation or code completion so we are good to run our code *)
			If[range[[1]] === range[[2]],
				FrontEndTokenExecute[nb, "ExpandSelection"]
			];
			NotebookApply[nb, "\\[AliasDelimiter]\\[SelectionPlaceholder]\\[AliasDelimiter]"]
		]
	]
];

(*
KeyBindings`OnTab[] := Module[{nb, selectionInfo}, 
	nb = SelectedNotebook[];
	selectionInfo = FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[nb];
	If[("CellSelectionType" /. selectionInfo) === "ContentSelection",
		FrontEndExecute @ FrontEndToken[nb, "Tab"];
		If[selectionInfo === FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[nb],
			(*If hitting tab does nothing then its not for navigation or code completion so we are good to run our code*)
			FrontEndTokenExecute[nb, "ExpandSelection"];
			NotebookApply[nb, "\\[AliasDelimiter]\\[SelectionPlaceholder]\\[AliasDelimiter]"]
		]
	]
];
*)

KeyBindings`Desurround[] := Module[{nb, selection, range, first, last},
  nb = SelectedNotebook[];
  selection = NotebookRead[nb];
  range = "CharacterRange" /. 
    FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[nb];
  first = KeyBindings`FirstCharacter@selection;
  last = KeyBindings`LastCharacter@selection;
  If[(first === "[" && last === "]") ||
    (first === "{" && last === "}") ||
    (first === "(" && last === ")") ||
    (first === "\"" && last === "\"") ||
    (first === "<" && last === ">") ||
    (first === "|" && last === "|") ||
    (first === "\[LeftAssociation]" && last === "\[RightAssociation]"),
   FrontEndExecute @ FrontEndToken[SelectedNotebook[], "MoveNext"];
   FrontEndExecute @ FrontEndToken[SelectedNotebook[], "DeletePrevious"];
   SelectionMove[nb, Previous, Character, range[[2]] - range[[1]] - 1];
   FrontEndExecute @ FrontEndToken[SelectedNotebook[], "DeleteNext"];
   SelectionMove[nb, All, Character, range[[2]] - range[[1]] - 2];
   ];
  If[first === "<" && last === ">",
   KeyBindings`Desurround[]
   ];
  ];

(* Note: If selection is on a cell (or cell group) then Ctrl + Up/Down
doesn't do anything (I wasn't sure what it should do) *)
KeyBindings`OnControlUp[] := Module[{nb}, 
	nb = SelectedNotebook[];
	Switch["CellSelectionType" /. FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[nb],
		"ContentSelection",
		SelectionMove[nb, All, Cell];
		FrontEndExecute @ FrontEndToken[nb, "MoveNext"];
		FrontEndExecute @ FrontEndToken[nb, "MovePrevious"],
		"AboveCell" | "BelowCell",
		KeyBindings`MoveUpCell[],
		_,
		Null
	]
];

KeyBindings`OnControlDown[] := Module[{nb}, 
	nb = SelectedNotebook[];
	Switch["CellSelectionType" /. FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[nb],
		"ContentSelection",
		SelectionMove[nb, All, Cell];
		FrontEndExecute @ FrontEndToken[nb, "MovePrevious"];
		FrontEndExecute @ FrontEndToken[nb, "MoveNext"],
		"AboveCell" | "BelowCell",
		KeyBindings`MoveDownCell[],
		_,
		Null
	]
];

(* All four of these cell actions assume you are between cells. Their behaviour
is unpredictable otherwise. I should consider renaming these to use
Previous and Next instead of Up and Down. Note: another possible value
for UndocumentedGetSelectionPackets "CellSelectionType" is "NoNotebookSelection" *)
KeyBindings`MoveUpCell[] := Module[{nb},
	nb = SelectedNotebook[];
	KeyBindings`SelectUpCell[];
	Switch["CellSelectionType" /. FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[nb],
		"CellRangeSelection",
		FrontEndExecute @ FrontEndToken[nb, "MovePreviousLine"],
		"OnCell",
		FrontEndExecute @ FrontEndToken[nb, "MoveNext"];
		FrontEndExecute @ FrontEndToken[nb, "MovePrevious"]
	]
];

KeyBindings`MoveDownCell[] := Module[{nb},
	nb = SelectedNotebook[];
	KeyBindings`SelectDownCell[];
	Switch["CellSelectionType" /. FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[nb],
		"CellRangeSelection",
		FrontEndExecute @ FrontEndToken[nb, "MoveNextLine"],
		"OnCell",
		FrontEndExecute @ FrontEndToken[nb, "MovePrevious"]
		FrontEndExecute @ FrontEndToken[nb, "MoveNext"];
	]
];

KeyBindings`SelectUpCell[] := Module[{nb, content, cell},
	nb = SelectedNotebook[];
	FrontEndExecute @ FrontEndToken[nb, "MovePreviousLine"];
	SelectionMove[nb, All, Cell];
	cell = SelectedCells[nb][[1]];
	If[SelectionMove[nb, All, CellGroup] === $Failed,
		SelectionMove[cell, All, Cell];
	];
	If[Last @ SelectedCells[nb] =!= cell,
		SelectionMove[cell, All, Cell];
	];
];

KeyBindings`SelectDownCell[] := Module[{nb, content, cell},
	nb = SelectedNotebook[];
	FrontEndExecute @ FrontEndToken[nb, "MoveNextLine"];
	SelectionMove[nb, All, Cell];
	cell = SelectedCells[nb][[1]];
	If[SelectionMove[nb, All, CellGroup] === $Failed,
		SelectionMove[cell, All, Cell];
	];
	If[First @ SelectedCells[nb] =!= cell,
		SelectionMove[cell, All, Cell];
	];
];

KeyBindings`DeleteCell[] := Module[{nb},
	nb = SelectedNotebook[];
	Switch["CellSelectionType" /. FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[nb],
	
		"ContentSelection",
		SelectionMove[nb, All, Cell];
		NotebookDelete[nb],
		
		"BelowCell" | "AboveCell",
		KeyBindings`SelectUpCell[];
		NotebookDelete[nb],
		
		"OnCell" | "CellRangeSelection",
		NotebookDelete[nb]
	]
];

(* I suppose this should be DeleteDownCell or really DeleteNextCell
according to the naming scheme *)
KeyBindings`DeleteCellDown[] := Module[{nb},
	nb = SelectedNotebook[];
	Switch["CellSelectionType" /. FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[nb],
	
		"ContentSelection",
		SelectionMove[nb, All, Cell];
		NotebookDelete[nb],
		
		"BelowCell" | "AboveCell",
		KeyBindings`SelectDownCell[];
		NotebookDelete[nb],
		
		"OnCell" | "CellRangeSelection",
		NotebookDelete[nb]
	]
];

(* Takes the current selection, prints it in a new window along with 
the TraceView (see top of this file) of the expression. Mostly works *)
KeyBindings`TraceView[] := (
	Module[{selection, window},
		selection = NotebookRead[SelectedNotebook[]];
		window = CreateWindow[];
		NotebookWrite[window, selection];
		FrontEndExecute @ FrontEndToken[window, "MoveNextLine"];
		NotebookWrite[window, 
			ToBoxes @ (TraceView @@ MakeExpression @ selection)];
		FrontEndExecute @ FrontEndToken[window, "MoveNextLine"];
		FrontEndExecute @ FrontEndToken[window, "MovePreviousLine"];
		FrontEndExecute @ FrontEndToken[window, "MoveNextLine"]
	]
);

(* Replaces the current selection with the MaTeX image of it. Unfinished *)
KeyBindings`MaTeX[] := (
	Needs["MaTeX`"];
);

(* This has a bug. It does not work when highlighting a function with a 
name of length 1. Eg: f[x,y], put cursor right of right bracket then Ctrl + 
Shfit + Left and the selection will only go up to the x, not the left bracket.
Not sure exactly what the fix for this is *)
(* Also, because "ExpandSelection" doesnt work the same in a text cell
as in a code cell (for some reason) this doesnt work in a code cell. I
could put a check in to fix that at some point 
	save selection location
	highlight cell and get its type
	if it is text cell
	then instead of using expand selection just read in everything 
		to the left and find the last space then highlight up to 
		there (that probably will work) *)
(* Also this didnt work in this case 
	bob[jeff_]
place the cursor between the last f of jeff and the _. Now try to Ctrl + 
Shift + Left or Ctrl + Left, you will see that it doesnt work *)
KeyBindings`SelectLeftPrevious[] := (
	If[
		$ActiveSideOfSelection === Neither,
		$ActiveSideOfSelection = Left
	];
	Quiet @ Module[{nb, range, prevChar, range2},
	  nb = SelectedNotebook[];
	  range = "CharacterRange" /. 
	   FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[nb];
	  If[
	   range[[1]] =!= range[[2]], 
	   FrontEndExecute @ FrontEndToken[nb, "MovePrevious"]
	   ];
	  FrontEndExecute @ FrontEndToken[nb, "SelectPrevious"];
	  prevChar = NotebookRead[nb];
	  (*Print@prevChar;*)
	  Which[
	   
	   (* Is it a backtick or period *)
	   
	   prevChar === "`" || prevChar === ".",
	   (* Then do this *)
	   (*Print@"backtick or period";*)
	   
	   FrontEndExecute @ FrontEndToken[nb, "SelectPreviousWord"],
	   
	   (* Is it a commma *)
	   prevChar === ",",
	   (* Then do this *)
	   (*Print@"comma";*)
	   
	   KeyBindings`SelectLeftWord[],
	   
	   (* Is it a word *)
	   
	   MatchQ[prevChar, 
	    Except["]" | "}" | ")" | "\[RightAssociation]" | ">" | "\"" | 
	      "\[RightDoubleBracket]", _String]],
	   (* If yes then do this *)
	   (*Print@"word";*)
	   
	   FrontEndExecute @ FrontEndToken[nb, "MoveNext"];
	   FrontEndExecute @ FrontEndToken[nb, "ExpandSelection"];
	   If[
	    NotebookRead[nb] == ".",
	    FrontEndExecute @ FrontEndToken[nb, "MovePrevious"];
	    FrontEndExecute @ FrontEndToken[nb, "SelectPreviousWord"]
	    ];
	   If[
	    NotebookRead[nb] == " ",
	    FrontEndExecute @ FrontEndToken[nb, "SelectPreviousWord"]
	    ],
	   
	   (* Is it a ] or \[RightDoubleBracket] *)
	   
	   prevChar === "]" || prevChar === "\[RightDoubleBracket]",
	   (* If yes then do this *)
	   (*Print@"] or \[RightDoubleBracket]";*)
	
	      FrontEndExecute @ FrontEndToken[nb, "ExpandSelection"];
	   FrontEndExecute @ FrontEndToken[nb, "MovePrevious"];
	   FrontEndExecute @ FrontEndToken[nb, "SelectNext"];
	   If[NotebookRead[nb] === "[",
	    FrontEndExecute @ FrontEndToken[nb, "ExpandSelection"],
	    FrontEndExecute @ FrontEndToken[nb, "MoveNext"];
	    FrontEndExecute @ FrontEndToken[nb, "MoveNextWord"]
	    ],
	   
	   (* Is it a box thing *)
	   MatchQ[prevChar, Except[_String]],
	   (* If yes then do this *)
	   (*Print@"box thing";*)
	   Null (* So MMA doesnt get mad on startup *),
	   
	   (* Then it must be one of } ) \[RightAssociation] > "*)
	   True,
	   (*Print@"one of } ) \[RightAssociation] > \"";*)
	   
	   FrontEndExecute @ FrontEndToken[nb, "ExpandSelection"];
	   If[
	    MatchQ[NotebookRead[nb], "*)" | "|>"],
	    FrontEndExecute @ FrontEndToken[nb, "ExpandSelection"]
	    ]
	   ];
	  range2 = 
	   "CharacterRange" /. 
	    FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[nb];
	  SelectionMove[nb, All, Character, range[[2]] - range2 [[1]]]
	  ]
);

KeyBindings`SelectRightNext[] := (
	If[
		$ActiveSideOfSelection === Neither,
		$ActiveSideOfSelection = Right
	];
	Quiet @ Module[{nb, range, nextChar, range2},
	  nb = SelectedNotebook[];
	  range = "CharacterRange" /. 
	    FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[nb];
	  If[
	   range[[1]] =!= range[[2]], 
	   FrontEndExecute @ FrontEndToken[nb, "MoveNext"]
	   ];
	  FrontEndExecute @ FrontEndToken[nb, "SelectNext"];
	  nextChar = NotebookRead[nb];
	  (*Print@nextChar;*)
	  Which[
	   
	   (* Is it a backtick or period *)
	   
	   nextChar === "`" || nextChar === ".",
	   (* Then do this *)
	   (*Print@"backtick or period";*)
	   
	   FrontEndExecute @ FrontEndToken[nb, "SelectNextWord"],
	   
	   (* Is it a commma a space or an indenting newline *)
	   
	   nextChar === "," || nextChar === " " || nextChar === "\[IndentingNewLine]",
	   (* Then do this *)
	   (*Print@"comma space or indenting newline";*)
	
	      KeyBindings`SelectRightWord[],
	   
	   (* Is it a word *)
	   
	   MatchQ[nextChar, 
	    Except["[" | "{" | "(" | "\[LeftAssociation]" | "<" | "\"" | 
	      "\[LeftDoubleBracket]", _String]],
	   (* If yes then do this *)
	   (*Print@"word";*)
	   
	   FrontEndExecute @ FrontEndToken[nb, "MoveNext"];
	   FrontEndExecute @ FrontEndToken[nb, "ExpandSelection"],
	   
	   (* Is it a [ or \[LeftDoubleBracket] *)
	   
	   nextChar === "[" || nextChar === "\[LeftDoubleBracket]",
	   (* If yes then do this *)
	   (*Print@"[ or \[LeftDoubleBracket]";*)
	
	   FrontEndExecute @ FrontEndToken[nb, "ExpandSelection"];
	   FrontEndExecute @ FrontEndToken[nb, "MoveNext"];
	   KeyBindings`SelectLeftWord[],
	   
	   (* Is it a box thing *)
	   MatchQ[nextChar, Except[_String]],
	   (* If yes then do this *)
	   (*Print@"box thing";*)
	   Null (* So MMA doesnt get mad on startup *),
	   
	   (* Then it must be one of { ( \[LeftAssociation] < " *)
	   True,
	   (*Print@"one of { ( \[LeftAssociation] < \"";*)
	   
	   FrontEndExecute @ FrontEndToken[nb, "ExpandSelection"];
	   If[
	    MatchQ[NotebookRead[nb], "(*" | "<|"],
	    FrontEndExecute @ FrontEndToken[nb, "ExpandSelection"]
	    ]
	   ];
	  range2 = "CharacterRange" /. 
	    FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[nb];
	  SelectionMove[nb, Before, CellContents, AutoScroll -> False];
	  SelectionMove[nb, Next, Character, range[[1]], AutoScroll -> False];
	  SelectionMove[nb, All, Character, range2[[2]] - range [[1]], AutoScroll -> False]
	  ]
);

KeyBindings`MoveLeftWord[] := (
	$ActiveSideOfSelection = Neither;
	If[
		NotebookRead[SelectedNotebook[]] =!= {},
		FrontEndExecute @ FrontEndToken[SelectedNotebook[], "MovePrevious"]
	];
	KeyBindings`SelectLeftPrevious[];
	FrontEndExecute @ FrontEndToken[SelectedNotebook[], "MovePrevious"]
);

KeyBindings`MoveRightWord[] := (
	$ActiveSideOfSelection = Neither;
	If[
		NotebookRead[SelectedNotebook[]] =!= {},
		FrontEndExecute @ FrontEndToken[SelectedNotebook[], "MoveNext"]
	];
	KeyBindings`SelectRightNext[];
	FrontEndExecute @ FrontEndToken[SelectedNotebook[], "MoveNext"]
);

(* Not being used because it doesnt work the way I want it to *)
KeyBindings`OnControlShiftLeft[] := (
	Module[{nb, range, range2},
		nb = SelectedNotebook[];
		range = "CharacterRange" /. 
			FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[nb];
		FrontEndExecute @ FrontEndToken[SelectedNotebook[], "SelectPrevious"];
		range2 = "CharacterRange" /. 
			FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[nb];
		FrontEndExecute @ FrontEndToken[SelectedNotebook[], "SelectNext"];
		If[
			range2[[2]] - range2[[1]] > range[[2]] - range[[1]],
			(* The selection got bigger therefore the active side is left *)
			KeyBindings`SelectLeftPrevious[],
			(* The selection got smaller therefore the active side is right *)
			FrontEndExecute @ FrontEndToken[SelectedNotebook[], "SelectNext"];
			KeyBindings`SelectLeftPrevious[];
			FrontEndExecute @ FrontEndToken[SelectedNotebook[], "MovePrevious"];
			range2 = "CharacterRange" /. 
				FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[nb];
			SelectionMove[nb, Before, CellContents, AutoScroll -> False];
			SelectionMove[nb, Next, Character, range[[1]], AutoScroll -> False];
			SelectionMove[nb, All, Character, range2[[2]] - range[[1]], AutoScroll -> False]
			
		];
	]
);

(* Not being used because it doesnt work the way I want it to *)
KeyBindings`OnControlShiftRight[] := (
	Module[{nb, range, range2},
		nb = SelectedNotebook[];
		range = "CharacterRange" /. 
			FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[nb];
		FrontEndExecute @ FrontEndToken[SelectedNotebook[], "SelectNext"];
		range2 = "CharacterRange" /. 
			FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[nb];
		FrontEndExecute @ FrontEndToken[SelectedNotebook[], "SelectPrevious"];
		If[
			range2[[2]] - range2[[1]] > range[[2]] - range[[1]],
			(* The selection got bigger therefore the active side is right *)
			KeyBindings`SelectRightPrevious[],
			(* The selection got smaller therefore the active side is left *)
			FrontEndExecute @ FrontEndToken[SelectedNotebook[], "SelectPrevious"];
			KeyBindings`SelectRightNext[];
			FrontEndExecute @ FrontEndToken[SelectedNotebook[], "MoveNext"];
			range2 = "CharacterRange" /. 
				FrontEndExecute @ FrontEnd`UndocumentedGetSelectionPacket[nb];
			SelectionMove[nb, All, Character, range[[2]] - range2[[1]], AutoScroll -> False]
		];
	]
);





















