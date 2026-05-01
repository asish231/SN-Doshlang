# Windows Verification

## Scope

This note records the current Windows-related verification status for `snc`.

## Verified

- `build.ps1` now defaults to `aarch64-windows-msvc` on Windows when no target is provided.
- `build.ps1` now warns clearly when run on an `x64` Windows host that the produced `snc.exe` will be ARM64 and will not run natively on that machine.
- `build.ps1` now chooses `.obj` output when targeting Windows.
- `README.md` now documents the Windows ARM64 cross-build behavior and the direct `-Clang` path option.

## Not fully verified yet

- A full Windows build has not been completed in this workspace because `clang` is not currently available on `PATH`.
- Native execution of `snc.exe` has not been verified here because this machine is `x64`, while the compiler codebase is still ARM64 assembly.

## Recommended next test

Run one of the following on a Windows machine with LLVM installed:

```powershell
./build.ps1
```

or:

```powershell
./build.ps1 -Clang "C:\Program Files\LLVM\bin\clang.exe"
```

Then verify:

- `snc.exe` is produced successfully
- the binary runs on Windows ARM64
- on `x64` Windows, the result is treated as a cross-build artifact only
