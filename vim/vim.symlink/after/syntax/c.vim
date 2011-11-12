" TODO:
"     - Don't match namespace::enum::value

syn keyword cType    i8 i16 i32 i64 i65 
syn keyword cType    u8 u16 u32 u64 
syn keyword cType    f32 f64 
syn keyword cType    ViStatus ViSession ViBoolean
syn keyword cType    ViString ViConstString
syn keyword cType    ViInt32 ViInt16 ViInt8
syn keyword cType    ViUInt32 ViUInt16 ViUInt8
syn keyword cType    ViReal64 ViReal32
syn match   cType    "\(\w\+\)\@<!\(\w\+ *:: *\)*[it][A-Z0-9]\w\+"

