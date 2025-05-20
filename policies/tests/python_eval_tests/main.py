import json

enable_print = 0


def lookup(whitelist: dict, key: any) -> list:
    return whitelist.get(key, [])


def blacklisted(blacklist: dict, vendor_id: any, product_id: any) -> bool:
    blacklisted_products = blacklist.get(vendor_id)
    if blacklisted_products is not None:
        return product_id in blacklisted_products
    else:
        neg_vendor = f"~{vendor_id}"
        whitelisted_products = blacklist.get(neg_vendor)
        if whitelisted_products is not None:
            return product_id not in whitelisted_products
        else:
            return False


def is_vm_filtered(
    vm_device_filter: dict, vm: any, device_key_0: any, device_key_1: any
) -> bool:
    devices = vm_device_filter.get(vm, [])
    if device_key_0 in devices:
        return True

    if device_key_1 in devices:
        return True

    return False


def filter_vms(vm_device_filter: dict, sorted_vms: list, key0: any, key1: any) -> list:
    filtered_vms = [
        vm for vm in sorted_vms if not is_vm_filtered(vm_device_filter, vm, key0, key1)
    ]

    return filtered_vms


def get_allowed_vms(
    json_data,
    device_class: int,
    subclass: int,
    protocol: int,
    vendor_id: int,
    product_id: int,
):
    result = json_data
    blacklist = result.get("blacklist", [])
    whitelist = result.get("whitelist", [])
    class_rules = result.get("class_rules", {})
    vm_device_filter = result.get("device_filter", [])

    # Check if the device is blacklisted
    if blacklisted(blacklist, vendor_id, product_id):
        return []

    # Check if the device is mapped to a specific VM
    device_key_0 = f"{vendor_id}:{product_id}"
    device_key_1 = f"{vendor_id}:*"
    wl_vms = lookup(whitelist, device_key_0) + lookup(whitelist, device_key_1)

    # Based on class, subclass, and protocol find list VMs which can access it
    class_key_0 = f"{device_class}:{subclass}:{protocol}"
    class_key_1 = f"{device_class}:{subclass}:*"
    class_key_2 = f"{device_class}:*:{protocol}"
    class_key_3 = f"{device_class}:*:*"
    cl_01_vms = lookup(class_rules, class_key_0) + lookup(class_rules, class_key_1)
    cl_23_vms = lookup(class_rules, class_key_2) + lookup(class_rules, class_key_3)
    cl_vms = cl_01_vms + cl_23_vms

    # Merge VMs from all above rules
    arr_vms = wl_vms + cl_vms
    unique_vms_set = list(set(arr_vms))

    # Filter any VM if it is disabled by the VM
    allowed_vms = filter_vms(
        vm_device_filter, unique_vms_set, device_key_0, device_key_1
    )

    return allowed_vms


def compare_results(list1, list2):
    if len(list1) == len(list2):
        for elm in list1:
            if elm not in list2:
                return "❌ FAIL"
        return "✅ PASS"
    return "❌ FAIL"


def remove_comments(json_as_string):
    result = ""
    for line in json_as_string.splitlines():
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        # Remove inline comment
        code_part = line.split("#", 1)[0].rstrip()
        if code_part:
            result += code_part + "\n"
    return result


def run_test(
    test_id,
    rules,
    device_class,
    subclass,
    vendor_id,
    product_id,
    protocol,
    expected_vms,
):
    vms = get_allowed_vms(
        rules,
        device_class=device_class,
        subclass=subclass,
        vendor_id=vendor_id,
        product_id=product_id,
        protocol=protocol,
    )
    result = compare_results(expected_vms, vms)
    print(
        f"{test_id}: expected: {expected_vms!s:<30} received: {vms!s:<30} Result: {result}"
    )


############TESTS###############

if __name__ == "__main__":
    json_string = """{
        "rules": {
           "_blacklist_" : [ 
              "List of blacklisted devices.",
              "Format: vendor_id : [list of products].",
              "       ~vendor_id : [list of products].",
              "When starts with ~, all the products of the vendor will be blacklisted except the listed ones.",
              "Vendor and product IDs must be 4 digit hex in 0x00ab format."
            ],  
            "blacklist": {
                "0xbadb" : ["0xdada"],
                "~0xbabb" : ["0xcaca"]
           },  

           "_whitelist_" : [ 
             "List of devices and VMs which are allowed to access it.",
             "Format: <vendor_id:product_id> : [list of allowed vms].",
             "        <vendor_id:*> : [list of allowed vm].",
             "* indicates all products of the vendor.",
             "vendor and product IDs must be 4 digit hex in 0x00ab format."
           ],  
           "whitelist" : { 
             "0x0b95:0x1790" : ["net-vm"]
           },  

           "_class_rules_" : [ 
             "Device with specific class, subclass, and protocol and it's mapping to VMs.",
             "Format: <class:subclass:protocol> : [list of allowed vms].",
             "* can be used for subclass and protocol.",
             "* indicates all values of that category is accepted.",
             "Must be 2 digit hex in 0x0a format."
           ],  
           "class_rules" : { 
               "0x01:*:*" : ["audio-vm"],
               "0x03:*:0x01" : ["gui-vm"],
               "0x03:*:0x02" : ["gui-vm"],
               "0x08:0x06:*" : ["gui-vm"],
               "0x0b:*:*" : ["gui-vm"],
               "0x11:*:*" : ["gui-vm"],
               "0xe0:0x01:0x01" : ["gui-vm"],
               "0x02:06:*" : ["net-vm"],
               "0x0e:*:*" : ["chrome-vm"]
           },  

           "_device_filter_" : [ 
             "Listed devices will be filtered out from the vm.",
             "Format: <vm-name> : [list of <vendor_id:product_id>].",
             "Vendor and product IDs must be 4 digit hex in 0x00ab format."
           ],  
           "device_filter" : { 
               "chrome-vm": ["0x04f2:0xb751", "0x5986:0x2145", "0x30c9:0x0052", "0x30c9:0x005f"]
           }   
        }
    }
    """

    with open("../../policies/usb_hotplug_rules.json") as fp:
        data = json.load(fp)

    rules = data["usb_hotplug_rules"]

    run_test(
        test_id="TEST1",
        rules=rules,
        device_class="0xff",
        subclass="0x01",
        vendor_id="0x0b95",
        product_id="0x1790",
        protocol=0,
        expected_vms=["net-vm"],
    )

    run_test(
        test_id="TEST2",
        rules=rules,
        device_class="0x01",
        subclass="0x02",
        vendor_id="0xdead",
        product_id="0xbeef",
        protocol="0x01",
        expected_vms=["audio-vm"],
    )

    run_test(
        test_id="TEST3",
        rules=rules,
        device_class="0x0e",
        subclass="0x02",
        vendor_id="0x04f2",
        product_id="0xb751",
        protocol="0x01",
        expected_vms=[],
    )

    run_test(
        test_id="TEST4",
        rules=rules,
        device_class="0x0e",
        subclass="0x02",
        vendor_id="0x04f2",
        product_id="0xb755",
        protocol="0x01",
        expected_vms=["chrome-vm"],
    )

    run_test(
        test_id="TEST5",
        rules=rules,
        device_class="0xe0",
        subclass="0x01",
        vendor_id="0x04f2",
        product_id="0xb755",
        protocol="0x01",
        expected_vms=[],
    )

    run_test(
        test_id="TEST6",
        rules=rules,
        device_class="0xe0",
        subclass="0x01",
        vendor_id="0xbadb",
        product_id="0xdada",
        protocol="0x01",
        expected_vms=[],
    )

    run_test(
        test_id="TEST7",
        rules=rules,
        device_class="0xe0",
        subclass="0x01",
        vendor_id="0xbabb",
        product_id="0xcaca",
        protocol="0x01",
        expected_vms=[],
    )

    run_test(
        test_id="TEST8",
        rules=rules,
        device_class="0xe0",
        subclass="0x01",
        vendor_id="0xbabb",
        product_id="0xb755",
        protocol="0x01",
        expected_vms=[],
    )
