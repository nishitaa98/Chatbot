original = " 0226-..**-2185.. 0030043713716".ljust(200)

# take user inputs
teller_no = input("Enter teller no (7 chars): ").ljust(7)
group_no = input("Enter group no (2 chars): ").ljust(2)
cap_level = input("Enter capability level (2 chars): ").ljust(2)
user_name = input("Enter user name (13 chars): ").ljust(13)
branch_no = input("Enter branch no (5 chars): ").ljust(5)
user_type = input("Enter user type (2 chars): ").ljust(2)

# convert to list (mutable)
data = list(original)

# replace fixed positions
data[113:120] = teller_no
data[120:122] = group_no
data[122:124] = cap_level
data[124:137] = user_name
data[151:156] = branch_no
data[167:169] = user_type

# back to string
updated_string = "".join(data)

print("Final String:")
print(updated_string)