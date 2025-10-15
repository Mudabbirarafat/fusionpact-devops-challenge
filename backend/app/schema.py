from typing import List
from pydantic import BaseModel

class UserIn(BaseModel):
    first_name: str
    last_name: str
    age: int

class BaseResponse(BaseModel):
    success: bool

class UserListOut(BaseModel):
    data: List[UserIn]