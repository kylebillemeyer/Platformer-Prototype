tool
extends Node

func contains_any(array: Array, values: Array) -> bool:
    for v in values:
     if array.find(v) > -1:
        return true
        
    return false
