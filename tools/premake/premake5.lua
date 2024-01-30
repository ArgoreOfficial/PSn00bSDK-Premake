local path = require "./path"
PROJECT_NAME = path.getProjectName( 2 )

local PSN00BSDK_INCLUDES = os.getenv( "PSN00BSDK_INCLUDES" );

rule "psx_compile"
  display "Compiling PSX"
  fileextension ".c"

  buildmessage "Building %(filename) to %(cfg.targetdir)"
  buildcommands 'mipsel-none-elf-gcc.exe -DPSN00BSDK=1 -ID:/SDK/PSn00bSDK-0.24-win32/lib/libpsn00b/cmake/../../../include/libpsn00b -g -g -Wa,--strip-local-absolute -ffreestanding -fno-builtin -nostdlib -fdata-sections -ffunction-sections -fsigned-char -fno-strict-overflow -fdiagnostics-color=always -msoft-float -march=r3000 -mtune=r3000 -mabi=32 -mno-mt -mno-llsc -Og -mdivide-breaks -G8 -fno-pic -mno-abicalls -mgpopt -mno-extern-sdata -o "./%(Filename).obj" -c "%(FullPath)"'
  buildoutputs '%(IntDir)/%(Filename).obj'



workspace (PROJECT_NAME)
	configurations { "Debug", "Release" }
	platforms { "x64" }
	location "../../"

project (PROJECT_NAME)
	kind "ConsoleApp"
	language "C"
	cdialect "Default"

	prebuildcommands { 
		-- "cmake --build ./",
		"echo hello"
	}

	rules { 
		"psx_compile" 
	}
	
	targetdir "../../bin"
	objdir "../../bin/obj/"

	location "../../build"

	includedirs {
		PSN00BSDK_INCLUDES
	}

	files { 
		"../../src/**.h", 
		"../../src/**.c" 
	}
