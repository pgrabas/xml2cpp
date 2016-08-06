

local BaseType, BaseType_mt = { }, { }
x2c.BaseType = BaseType
x2c.BaseType_mt = BaseType_mt

function x2c.MakeTypeClass()
	local base = x2c.BaseType

    local class = {}
    local mt = { 
		__index = class, 
		__call = BaseType_mt.__call, 
		__newindex = BaseType_mt.__newindex,
		__tostring = BaseType_mt.__tostring,
	}

--    function class:create()
--        return setmetatable( { } , mt )
--    end

    setmetatable( class, { __index = BaseType } )

    return class, mt
end

function BaseType_mt.__newindex(self)
	error("Attempt to modify ", self:Type(), " type")
end

function BaseType_mt.__call(self, arg)
	error("Cannot call ", self:Type(), " type")
	return nil
end

function BaseType_mt.__tostring(self)
	return string.format("%s(%s)", self.object_type, self:GlobalName())
end

function BaseType:GenResetToDefault(member, name, writter)
	writter:DefLine {
		self:GlobalName(),
		"_SetDefault(", member, ");",
	}
end

function BaseType:GenWrite(member, name, writter)
	writter:DefLine { 
		"if(!", 
		self:GlobalName(), 
		"_Write(node, ", 
		member, 
		", ", name,
		")) return false;", 
	}	
end

function BaseType:GenRead(member, name, writter)
	writter:DefLine { 
		"if(!", 
		self:GlobalName(), 
		"_Read(node, ", 
		member, 
		", ", name,
		")) return false;", 
	}
end

function BaseType:Type()
	return self.object_type or "Unknown"
end

function BaseType:GlobalName()
	return self.namespace:GlobalName() .. "::" .. self:LocalName()
end

function BaseType:LocalName()
	return self.local_name or self:GetName()
end

function BaseType:GetName()
	return self.name
end

function BaseType:DisplayName()
	return self:GlobalName()
end

-----------------------------------------------------

local function fullname(obj)
	local o = rawget(obj, "owner")
	if not o then
		return rawget(obj, "name")
	end
	return fullname(o) .. "." .. rawget(obj, "name")
end

-----------------------------------------------------

local Meta_mt = { }

function Meta_mt.__newindex(self)
	error("Attempt to modify ", fullname(self), " metaobject!")
end

function Meta_mt.__call(self, ...)
	local f = rawget(self, "__call")
	if f then
		return f(self, ...)
	end
	error("Attempt to call ", fullname(self), " metaobject!")
end

function Meta_mt.__tostring(self)
	return fullname(self)
end

function Meta_mt.__index(self, key)
	local f = rawget(self, key)
	if not f then
		error(self, "there is no such operation - ", key)
	end
	
	return f
end

function x2c.MakeMetaObject(object, name)
	object.name = name
    setmetatable(object, Meta_mt)
	_G[name] = object
end

function x2c.MakeMetaSubObject(owner, object, name)
	object.name = name
	object.owner = owner
	owner[name] = object
    setmetatable(object, Meta_mt)
	return object
end