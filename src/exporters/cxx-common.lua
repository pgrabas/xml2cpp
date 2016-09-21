
--CXXWritter

local CXXWritter = inheritsFrom(x2c.Classes.Writter)
x2c.Classes.CXXWritter = CXXWritter

local CXXBlockExt = { }

function CXXBlockExt:BeginNamespace(name)
	self:BeginBlockLine { "namespace ", name, " {", }
end

function CXXBlockExt:EndNamespace()
	self:EndBlockLine { "}", }
end

function CXXWritter:Init(FileName)
	self.Base.Init(self, FileName)
	
	self.BlockExt = CXXBlockExt
	
	self.HeaderBlock = self:AddFileBlock()
	self.X2CImplBlock = self:AddFileBlock()
end

function CXXBlockExt:MakeAlias(name, srcname)
	self:Line { "using ", name, " = ", srcname, ";", }
end

function CXXBlockExt:DefineStructure(name)
	self:Line { "struct ", name, ";", }
end

function CXXBlockExt:BeginStructure(name)
	self:BeginBlockLine { "struct ", name, " {", }
end

function CXXBlockExt:EndStructure()
	self:EndBlockLine { "};", }
end

function CXXBlockExt:DocString(text)
	local t = type(text)
	if t == "table" then
		self:Line { "/** ", (table.unpack)(text), " */", }
	end
	if t == "string" then
		self:Line { "/** ", text, " */", }
	end	
end

function CXXWritter:WriteFileHeader()
	local block = self.HeaderBlock
	block:Line "/*"
	block:SetLinePrefix(" *  ")
	
	local cdate = os.date("*t")
	local sdate = string.format("%04d-%02d-%02d %02d:%02d:%02d", cdate.year, cdate.month, cdate.day, cdate.hour, cdate.min, cdate.sec)	  
	
	block:Line { }
	block:Line { "File generated by ", x2c.info.LongName, " cxx-pugi exporter" }
	block:Line { "Do not edit manually"	}
	block:Line { }
	block:Line { "Generated at ", sdate }
--	block:Line { "From ", } TBD
	block:Line { }
	
	block:SetLinePrefix(nil)
	block:Line " */"
	block:Line "#pragma once"
	block:Line { }
end

function CXXWritter:WriteX2CImpl(ImplList)
	local block = self.X2CImplBlock
	
	block:Line { "#ifndef _X2C_IMPLEMENTATION_" } 
	block:Line { "#define _X2C_IMPLEMENTATION_" } 
	block:BeginNamespace("x2c")
	block:BeginNamespace("cxxpugi")
	
	block:Line { "template<bool Required, bool Attribute, class Type, class Reader>" }
	block:Line { "inline bool Read(Type &, Reader, const char *);"}
	
	block:Line { "template<bool Attribute, class Type, class Reader>" }
	block:Line { "inline bool Write(const Type &, Reader, const char *);"}	
	
	block:Line { }
	
	local first = true
	for i,v in pairs(ImplList) do
		if not first then
			block:Line { }
		end
		first = false
		v:GenImplementation(block)
	end
	
	block:Line { }
	
	block:BeginStructure("StructureMemberInfo")
	block:Line "std::string m_Name;"
	block:Line "std::string m_Default;"
	block:Line "std::string m_Description;"
	block:Line "std::string m_TypeName;"
	block:EndStructure()
	block:MakeAlias("StructureMemberInfoTable", "std::vector<StructureMemberInfo>")
	
	block:EndNamespace()
	block:EndNamespace()
	block:Line { "#endif" } 
	block:Line { }
end