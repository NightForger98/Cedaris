/// @description A farm animal (see the animals script). Set on creation: data (its stored struct).
def = animal_def(data.kind);
dirIdx = 2;          // facing: 0 up, 1 left, 2 down, 3 right (the sheets' row order)
frame = 0;
moveX = 0;
moveY = 0;
wanderT = irandom(60);
heartT = 0;          // a heart floats up after petting
near = false;
