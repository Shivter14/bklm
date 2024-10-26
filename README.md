# Batch Keyboard Layout Editor for projects using `getInput64.dll` (+ standard)
I encountered a problem today - Shivtanium uses the Czech keyboard layout, but not everyone is Czech!
I could have solved this problem by making a few keyboard layouts, but then I realized most `getInput64.dll` projects that have input systems also have this problem. That's why I'm making a simple standard for loading keyboard layouts, and also an editor for them.

In this standard, a keyboard layout consists of 3 long variables:
* One of them contains characters to be used in a case where the user isn't holding SHIFT nor ALT
* The other one contains characters to be used in a case where the user is holding SHIFT
* The last one contains characters to be used in a case where the user is holding ALT
We can call these variables however we like, but for simplicity I'm going to refer to them as:
> `charset_L` (L for Lowercase)
> `charset_U` (U for Uppercase)
> `charset_A` (A for the ALT key)
With this system, we can convert a `getInput64.dll`/WinAPI keycode with this simple string expansion: ```bat
for %%k in (!keycode!) do if "!keysPressed!" neq "!keysPressed:-16-=!" (
  set "char=!charset_U:~%%k,1!"
) else if "!keysPressed!" neq "!keysPressed:-18-=!" (
  set "char=!charset_A:~%%k,1!"
) else set "char=!charset_L:~%%k,1!"
```
We're basically taking a single character from a string with the position being the keycode.
We also need to make a small check
> If the character is a space (` `), and the keycode isn't 32 (space bar), set the character to nothing, since we pressed a control key, or an undefined key.
```bat
if "!char!"==" " if "!keycode!" neq "32" set char=
```

More about the editor;
> Keyboard layouts can be imported and exported through the top menu.
> Click on any key to re-bind it to a different character.
> Running the editor with the 1st parameter being `/r` enables **recording mode**. This mode disables all buttons & click functions, effectively making this a keyboard display. Useful for recordings.
> cmdwiz.exe is used here along with an async timer to not eat the entire CPU while running.
