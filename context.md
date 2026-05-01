# Context

## What we were trying to do

We were trying to make `snc` work better on Windows.

The main goal was:

- improve the Windows build flow
- make the repo clearer about what works on Windows and what does not
- prepare the project for testing on a Windows machine

## What we found

- The compiler source is still written in ARM64 assembly.
- This means a normal `x64` Windows PC cannot run the produced `snc.exe` natively.
- An `x64` Windows PC can still cross-build an ARM64 Windows executable.
- `clang` was not available on `PATH` on the current machine, so a full build test could not be completed yet.

## What we changed

We updated `build.ps1` so that:

- on Windows, it now defaults to `aarch64-windows-msvc`
- it shows a clear warning on `x64` Windows hosts
- it uses `.obj` output when targeting Windows

We also updated `README.md` so the Windows instructions are clearer.

## Current status

Right now the Windows situation is:

- building is better configured
- documentation is clearer
- actual testing is still pending because `clang` is missing
- native execution on this current `x64` Windows machine is still not expected

## What we need to test

1. Install LLVM/Clang on Windows, or confirm its full path.
2. Run:

```powershell
./build.ps1
```

3. If `clang` is not on `PATH`, run:

```powershell
./build.ps1 -Clang "C:\Program Files\LLVM\bin\clang.exe"
```

4. Confirm that the build produces `snc.exe`.
5. If testing on a Windows ARM64 machine, try running the produced `snc.exe`.
6. If testing on an `x64` Windows machine, treat the result as a cross-build only.

## Important note

If the real goal is to make `snc` run natively on normal `x64` Windows, that is a bigger task.

That would likely require one of these:

- porting the compiler from ARM64 assembly to `x64` assembly
- rewriting the compiler in another language
- adding another backend that can run on `x64` Windows
