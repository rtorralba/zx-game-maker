import argparse

def zx_character(s):
    # Placeholder for ZX Spectrum character conversion
    return s

def bin2tap(buffer, header, address=0, block_type=0):
    # HEADER
    data = bytearray([0x13, 0x00, 0x00])

    # Block type: 0x00 Program, 0x03 Bytes
    data.append(0x03 if block_type == 0 else 0x00)

    # Header name
    header = zx_character(header).ljust(10)[:10]
    data.extend(header.encode('ascii'))

    # Fixed data (little endian)
    # Length buffer
    data.append(len(buffer) % 0x0100)
    data.append((len(buffer) // 0x0100) % 0x0100)
    # Param 1 (start address / start line)
    data.append(address % 0x0100)
    data.append((address // 0x0100) % 0x0100)
    # Param 2 (0x8000 / Var area)
    if block_type == 0:
        data.extend([0x00, 0x80])
    else:
        data.append(len(buffer) % 0x0100)
        data.append((len(buffer) // 0x0100) % 0x0100)

    # Header checksum (excludes bytes 0 & 1)
    checksum = 0x00
    for byte in data[2:]:
        checksum ^= byte
    data.append(checksum)

    # SOURCE
    # Source length + 2 bytes (Flag & checksum)
    length = len(buffer) + 0x02
    data.append(length % 0x0100)
    data.append((length // 0x0100) % 0x0100)
    # Byte flag
    data.append(0xff)
    # Source bytes
    data.extend(buffer)

    # Source checksum (includes byte flag)
    checksum = 0xff
    for byte in buffer:
        checksum ^= byte
    data.append(checksum)

    return bytes(data)

def bin2tap_from_stream(stream, header, address=0, block_type=0):
    buffer = stream.read()
    # Ensure buffer is a bytearray for consistent type handling
    buffer = bytearray(buffer)
    return bin2tap(buffer, header, address, block_type)

def main():
    parser = argparse.ArgumentParser(description="Convert a .bin file to a .tap file for ZX Spectrum.")
    parser.add_argument("input_file", help="Path to the input .bin file")
    parser.add_argument("output_file", help="Path to the output .tap file")
    parser.add_argument("address", type=int, help="Start address")
    parser.add_argument("--header", default="BIN", help="Header name (default: BIN)")
    parser.add_argument("--block_type", type=int, default=0, help="Block type (0 for bytes, 1 for program)")

    args = parser.parse_args()

    try:
        with open(args.input_file, 'rb') as input_file:
            tap_data = bin2tap_from_stream(input_file, args.header, args.address, args.block_type)

        with open(args.output_file, 'wb') as output_file:
            output_file.write(tap_data)

        print("Successfully converted {} to {}".format(args.input_file, args.output_file))
    except IOError as e:
        print("Error: {}".format(e))

if __name__ == "__main__":
    main()