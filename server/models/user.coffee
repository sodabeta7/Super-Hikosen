mongoose=require('mongoose')
Schema=mongoose.Schema


UserSchema=new Schema({
  id: String
  name: String
  maxscore: double
  passwordHash: String
  passwordSalt: String
})

module.exports=mongoose.model('User',UserSchema)