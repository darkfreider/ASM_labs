
scale = 8
epsilon = 1

def float_to_fixed(i):
	return i * (1 << scale)

def fixed_to_float(i):
	return i / (1 << scale)

def int_to_fixed(i):
	return i << scale

def fixed_to_int(i):
	return i >> scale

print(float_to_fixed(1.23))
print( fixed_to_float(314) )

print( float_to_fixed(1 / 20) )

print( int_to_fixed(10) )
print( int_to_fixed(-10) )

print( float_to_fixed(1 / 30) )







