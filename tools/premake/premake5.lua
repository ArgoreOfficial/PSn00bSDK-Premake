local proj_path = require "./path"
PROJECT_NAME = proj_path.getProjectName( 2 )

PSN00BSDK_INCLUDES = os.getenv( "PSN00BSDK_INCLUDES" );
PSN00BSDK_LIBS = os.getenv( "PSN00BSDK_LIBS" );

TARGET_DIR = "bin/"

BUILDLIST = ""
local matches = os.matchfiles("../../src/**.c")
for _, v in ipairs(matches) do 
	BUILDLIST = BUILDLIST .. "%{cfg.objdir}" .. ( path.getbasename( v ) ) .. ".obj "
end

rule "psx_compile"
  display "Compiling PSX"
  fileextension ".c"

  buildmessage "%(filename).c"

  buildcommands {
		'mipsel-none-elf-gcc.exe -DPSN00BSDK=1 -I %{PSN00BSDK_INCLUDES} -g -g -Wa,--strip-local-absolute -ffreestanding -fno-builtin -nostdlib -fdata-sections -ffunction-sections -fsigned-char -fno-strict-overflow -fdiagnostics-color=always -msoft-float -march=r3000 -mtune=r3000 -mabi=32 -mno-mt -mno-llsc -Og -mdivide-breaks -G8 -fno-pic -mno-abicalls -mgpopt -mno-extern-sdata -MD -MT %{cfg.objdir}%(Filename).obj -MF %{cfg.objdir}%(Filename).obj.d -o %{cfg.objdir}%(Filename).obj -c %(FullPath)'
  }
  buildoutputs ''


workspace (PROJECT_NAME)
	configurations { "Debug", "Release" }
	platforms { "x64" }
	location "../../"

project (PROJECT_NAME)
	kind "ConsoleApp"
	language "C"
	cdialect "Default"

	rules { 
		"psx_compile" 
	}
	
	targetdir "%{wks.location}%{TARGET_DIR}"
	objdir "%{wks.location}%{TARGET_DIR}obj/"

	location "../../build"

	postbuildcommands {
		'mipsel-none-elf-g++.exe -g -T %{PSN00BSDK_LIBS}/ldscripts/exe.ld -nostdlib -Wl,-gc-sections -G8 -static %{BUILDLIST} -o %{wks.location}%{TARGET_DIR}%{prj.name}.elf  -lgcc  %{PSN00BSDK_LIBS}/debug/libpsxgpu_exe_gprel.a  %{PSN00BSDK_LIBS}/debug/libpsxgte_exe_gprel.a  %{PSN00BSDK_LIBS}/debug/libpsxspu_exe_gprel.a  %{PSN00BSDK_LIBS}/debug/libpsxcd_exe_gprel.a  %{PSN00BSDK_LIBS}/debug/libpsxpress_exe_gprel.a  %{PSN00BSDK_LIBS}/debug/libpsxsio_exe_gprel.a  %{PSN00BSDK_LIBS}/debug/libpsxetc_exe_gprel.a  %{PSN00BSDK_LIBS}/debug/libpsxapi_exe_gprel.a  %{PSN00BSDK_LIBS}/debug/libsmd_exe_gprel.a  %{PSN00BSDK_LIBS}/debug/liblzp_exe_gprel.a  %{PSN00BSDK_LIBS}/debug/libc_exe_gprel.a  -lgcc ',
		'elf2x.exe -q %{wks.location}%{TARGET_DIR}%{prj.name}.elf %{wks.location}%{TARGET_DIR}%{prj.name}.exe',
		'mipsel-none-elf-nm.exe -f posix -l -n %{wks.location}%{TARGET_DIR}%{prj.name}.elf > %{wks.location}%{TARGET_DIR}%{prj.name}.map'
		-- build iso files, requires xml file, I haven't gotten to porting that over yet
		--,'mkpsxiso.exe -y -o %{wks.location}%{TARGET_DIR}%{prj.name}.bin -c %{wks.location}%{TARGET_DIR}%{prj.name}.cue D:/Dev/PSn00bSDK-Premake/cmakebuild/cd_image_d00471dcf544c6cf.xml'
	}

	includedirs {
		PSN00BSDK_INCLUDES
	}

	files { 
		"../../src/**.h", 
		"../../src/**.c" 
	}
