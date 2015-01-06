/*
The MIT License (MIT)
Copyright (c) 2015 Hongjie Zhai
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

import io/BinarySequence
import structs/[Stack, HashMap, ArrayList]

BJsonOP: cover{
     END    := const static 0
     OPEN_OBJ   := const static 1
     OPEN_ARR   := const static 2
     CLOSE_OBJ  := const static 3
     CLOSE_ARR  := const static 4
     STRING := const static 5
     STRING_DIRECT  := const static 6
     MEMBER := const static 7
     MEMBER_DIRECT  := const static 8
     NUMBER_I64 := const static 9
     NUMBER_DBL := const static 10
     NUMBER_I32 := const static 11
     NUMBER_I16 := const static 12
     NUMBER_I8  := const static 13
     NUMBER_FLT := const static 14
     CTE_TRUE   := const static 15
     CTE_FALSE  := const static 16
     CTE_NULL   := const static 17
     NUMBER_I8_RLE  := const static 18
     NUMBER_I16_RLE := const static 19
     NUMBER_I32_RLE := const static 20
     NUMBER_I64_RLE := const static 21
     CTE_TRUE_RLE   := const static 22
     CTE_FALSE_RLE  := const static 23
}

CP: cover{
    str: String
    memberCache: Int
}

JsonNode: abstract class{ 
    indentLevel: Int = 0

    indent: func -> String{
        "  " * indentLevel
    }

    get: abstract func <T> (T: Class) -> T

    addVal: abstract func(j: JsonNode)
    addKey: abstract func(j: JsonNode)

    toString: abstract func -> String
}

JsonObject: class extends JsonNode{
    data := HashMap <JsonNode, JsonNode> new()

    currentKey : JsonNode
    waitingVal: Bool = false

    init: func

    get: func <T> (T: Class) -> T{
        match(T){
            case HashMap => return data
            case ArrayList<JsonNode> => return data keys
            case => Exception new("Can not get the type %s" format(T name)) throw()
        }
        null
    }

    addKey: func(j: JsonNode){
        currentKey = j
        waitingVal = true
    }

    addVal: func(j: JsonNode){
        if(!waitingVal){
            Exception new("Not paired key-val %s." format(j toString())) throw()
        }
        data put(currentKey, j)
        waitingVal = false
    }

    toString: func -> String{
        str := "{\n"
        first := true
        for(i:JsonNode in data keys){
            if(first){
                str += indent() + i toString() + " : " + data[i] toString()
                first = false
            } else {
                str += " ,\n" + indent() + i toString() + " : " + data[i] toString()
            }
        }
        str + "\n" + indent()+ "}"
    }
}

JsonArray: class extends JsonNode{
    data := ArrayList<JsonNode> new()

    init: func

    get: func <T> (T: Class) -> T{
        match(T){
            case ArrayList<JsonNode> => return data
            case => Exception new("Can not get the type %s" format(T name)) throw()
        }
        null
    }

    addKey: func(j: JsonNode){
        Exception new("Can not add key for array!") throw()
    }

    addVal: func(j: JsonNode){
        data add(j)
    }

    toString: func ->String{
        str := "[\n"
        first := true
        for(i in data){
            if(first){
                str += indent() + i toString()
                first = false
            } else {
                str += " ,\n" + indent() + i toString()
            }
        }
        str + "\n" + indent() + "]"
    }
}

JsonString: class extends JsonNode{
    data: String

    init: func(=data)

    get: func <T> (T: Class) -> T{
        match(T){
            case String => return data as String
            case CString => return data toCString() as CString
            case => Exception new("Can not get the type %s" format(T name)) throw()
        }

        null
    }

    addKey: func(j: JsonNode){
        Exception new("Can not add key for string!") throw()
    }

    addVal: func(j: JsonNode){
        Exception new("Can not add value for string!") throw()
    }

    toString: func -> String{ "\"" + data + "\"" }
}

JsonInt64: class extends JsonNode{
    data: Int64

    init: func(=data)

    get: func <T> (T: Class) -> T{
        match(T){
            case Int64 => return data
            case UInt64 => return data
            case String => return data toString()
            case => Exception new("Can not get the type %s" format(T name)) throw()
        }
        
        null
    }

    addKey: func(j: JsonNode){
        Exception new("Can not add key for int!") throw()
    }

    addVal: func(j: JsonNode){
        Exception new("Can not add value for int!") throw()
    }

    toString: func -> String{ data toString() }
}

JsonInt32: class extends JsonNode{
    data: Int32

    init: func(=data)

    get: func <T> (T: Class) -> T{
        match(T){
            case Int64 => return data
            case UInt64 => return data 
            case Int32 => return data
            case UInt32 => return data
            case String => return data toString()
            case => Exception new("Can not get the type %s" format(T name)) throw()
        }
        null
    }

    addKey: func(j: JsonNode){
        Exception new("Can not add key for int!") throw()
    }

    addVal: func(j: JsonNode){
        Exception new("Can not add value for int!") throw()
    }

    toString: func -> String{ data toString() }
}

JsonInt16: class extends JsonNode{
    data: Int16

    init: func(=data)

    get: func <T> (T: Class) -> T{
        match(T){
            case Int64 => return data
            case UInt64 => return data 
            case Int32 => return data
            case UInt32 => return data
            case Int16 => return data
            case UInt16 => return data
            case String => return data toString()
            case => Exception new("Can not get the type %s" format(T name)) throw()
        }
        null
    }

    addKey: func(j: JsonNode){
        Exception new("Can not add key for int!") throw()
    }

    addVal: func(j: JsonNode){
        Exception new("Can not add value for int!") throw()
    }

    toString: func -> String{ data toString() }
}

JsonInt8: class extends JsonNode{
    data: Int64

    init: func(=data)

    get: func <T> (T: Class) -> T{
        match(T){
            case Int64 => return data
            case UInt64 => return data
            case Int32 => return data
            case UInt32 => return data
            case Int16 => return data
            case UInt16 => return data
            case Int8 => return data
            case UInt8 => return data
            case String => return data toString()
            case => Exception new("Can not get the type %s" format(T name)) throw()
        }
        null
    }

    addKey: func(j: JsonNode){
        Exception new("Can not add key for int!") throw()
    }

    addVal: func(j: JsonNode){
        Exception new("Can not add value for int!") throw()
    }

    toString: func -> String{ data toString() }
}

JsonNull: class extends JsonNode{
    init: func()

    get: func <T> (T: Class) -> T{
        match(T){
            case Int64 => return 0
            case UInt64 => return 0
            case Int32 => return 0
            case UInt32 => return 0
            case Int16 => return 0
            case UInt16 => return 0
            case Int8 => return 0
            case UInt8 => return 0
            case Pointer => return null
            case String => return "Null"
            case => Exception new("Can not get the type %s" format(T name)) throw()
        }
        null
    }

    addKey: func(j: JsonNode){
        Exception new("Can not add key for null!") throw()
    }

    addVal: func(j: JsonNode){
        Exception new("Can not add value for null!") throw()
    }

    toString: func -> String{ "Null" }
}

JsonBoolean: class extends JsonNode{
    data: Bool

    init: func(=data)

    toInt: func -> Int8{
        data as Int8
    }

    get: func <T> (T: Class) -> T{
        match(T){
            case Int64 => return toInt()
            case UInt64 => return toInt()
            case Int32 => return toInt()
            case UInt32 => return toInt()
            case Int16 => return toInt()
            case UInt16 => return toInt()
            case Int8 => return toInt()
            case UInt8 => return toInt()
            case Bool => return data
            case String => return data toString()
            case => Exception new("Can not get the type %s" format(T name)) throw()
        }
        null
    }

    addKey: func(j: JsonNode){
        Exception new("Can not add key for boolean!") throw()
    }

    addVal: func(j: JsonNode){
        Exception new("Can not add value for boolean!") throw()
    }

    toString: func -> String{ data toString() }
}

JsonDouble: class extends JsonNode{
    data: Double

    init: func(=data)

    get: func <T> (T: Class) -> T{
        match(T){
            case Float => return data
            case Double => return data 
            case String => return data toString()
            case => Exception new("Can not get the type %s" format(T name)) throw()
        }
        null
    }

    addKey: func(j: JsonNode){
        Exception new("Can not add key for double!") throw()
    }

    addVal: func(j: JsonNode){
        Exception new("Can not add value for double!") throw()
    }

    toString: func -> String{ data toString() }
}

JsonFloat: class extends JsonNode{
    data: Float

    init: func(=data)

    get: func <T> (T: Class) -> T{
        match(T){
            case Float => return data
            case Double => return data 
            case String => return data toString()
            case => Exception new("Can not get the type %s" format(T name)) throw()
        }
        null
    }

    addKey: func(j: JsonNode){
        Exception new("Can not add key for float!") throw()
    }

    addVal: func(j: JsonNode){
        Exception new("Can not add value for float!") throw()
    }

    toString: func -> String{ data toString() }
}

BJson : class{
    cpList: ArrayList<CP> = ArrayList<CP> new()

    root: JsonNode = JsonArray new()

    toString: func -> String{
        ret := ""
        for(j in root){
            ret += j toString()
        }
        ret
    }

    init: func(buffer: BinarySequenceReader){
        if(buffer u16() != 0xFFFF){
            Exception new("Not a binary Json file.") throw()
        }

        cnt:= buffer u32()
        strSize := buffer u32()
        for(i in 0..cnt){
            cpList add((buffer pascalString(4), -1) as CP)
        }

        stack := Stack<JsonNode> new()
        stack push(root)

        while(buffer hasNext?()){
            match(buffer u8()){
                case BJsonOP END => break
                case BJsonOP OPEN_OBJ => 
                    size := buffer s32()
                    stack push(JsonObject new())
                    stack peek() indentLevel = stack size - 1
                case BJsonOP OPEN_ARR =>
                    size := buffer s32()
                    mask := buffer s32()
                    stack push(JsonArray new())
                    stack peek() indentLevel = stack size - 1
                case BJsonOP CLOSE_OBJ =>
                    v := stack pop()
                    stack peek() addVal(v)
                case BJsonOP CLOSE_ARR =>
                    v := stack pop()
                    stack peek() addVal(v)
                case BJsonOP STRING =>
                    stack peek() addVal(JsonString new(cpList[buffer u32()] str))
                case BJsonOP STRING_DIRECT =>
                    stack peek() addVal(JsonString new(buffer pascalString(4)))
                case BJsonOP MEMBER =>
                    stack peek() addKey(JsonString new(cpList[buffer u32()] str))
                case BJsonOP MEMBER_DIRECT =>
                    stack peek() addKey(JsonString new(buffer pascalString(4)))
                case BJsonOP NUMBER_I64 =>
                    stack peek() addVal(JsonInt64 new(buffer s64()))
                case BJsonOP NUMBER_DBL =>
                    stack peek() addVal(JsonDouble new(buffer float64()))
                case BJsonOP NUMBER_I32 =>
                    stack peek() addVal(JsonInt32 new(buffer s32()))
                case BJsonOP NUMBER_I16 =>
                    stack peek() addVal(JsonInt16 new(buffer s16()))
                case BJsonOP NUMBER_I8 =>
                    stack peek() addVal(JsonInt8 new(buffer s8()))
                case BJsonOP NUMBER_FLT =>
                    stack peek() addVal(JsonFloat new(buffer float32()))
                case BJsonOP CTE_TRUE =>
                    stack peek() addVal(JsonBoolean new(true))
                case BJsonOP CTE_FALSE =>
                    stack peek() addVal(JsonBoolean new(false))
                case BJsonOP CTE_NULL =>
                    stack peek() addVal(JsonNull new())
                case BJsonOP NUMBER_I8_RLE => // *_RLE is compressed data
                    data := buffer s8()
                    count := buffer u16()
                    for(i in 0..count){
                        stack peek() addVal(JsonInt8 new(data))
                    }
                case BJsonOP NUMBER_I16_RLE =>
                    data := buffer s16()
                    count := buffer u16()
                    for(i in 0..count){
                        stack peek() addVal(JsonInt16 new(data))
                    }
                case BJsonOP NUMBER_I32_RLE =>
                    data := buffer s32()
                    count := buffer u16()
                    for(i in 0..count){
                        stack peek() addVal(JsonInt32 new(data))
                    }
                case BJsonOP NUMBER_I64_RLE =>
                    data := buffer s64()
                    count := buffer u16()
                    for(i in 0..count){
                        stack peek() addVal(JsonInt64 new(data))
                    }
                case BJsonOP CTE_TRUE_RLE =>
                    count := buffer u16()
                    for(i in 0..count){
                        stack peek() addVal(JsonBoolean new(true))
                    }
                case BJsonOP CTE_FALSE_RLE =>
                    count := buffer u16()
                    for(i in 0..count){
                        stack peek() addVal(JsonBoolean new(false))
                    }
                case =>
                    Exception new("Unknow Operator Code") throw()
            }
        }
        stack pop()
        if(stack size > 0){
            Exception new("Stream[%d] not ended" format(stack size)) throw()
        }
    }
}
