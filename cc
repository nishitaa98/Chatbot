def parse_cheque_data(response_text):
    results = []

    index = 0
    while True:
        ci_index = response_text.find("CI", index)
        if ci_index == -1:
            break

        try:
            # Extract based on your logic
            branch_no = response_text[ci_index + 3 : ci_index + 7]
            from_check = response_text[ci_index + 12 : ci_index + 16]
            to_check = response_text[ci_index + 21 : ci_index + 25]

            results.append({
                "branch_no": branch_no.strip(),
                "from_check": from_check.strip(),
                "to_check": to_check.strip()
            })

        except Exception as e:
            print("Parsing error at index", ci_index, e)

        index = ci_index + 2  # move forward

    return results