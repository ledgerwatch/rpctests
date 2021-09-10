package qa_common

/* server and a client communication rules */

const (
	ERROR byte = 128 + iota
	OK
	WARN
	CONN_CLOSED

	END_OF_MESSAGE byte = 255
)

func NewResponse(bytes []byte, kind byte) []byte {
	// first byte: type of message - ERROR, OK, WARN, etc
	// msg[first:last-1] = message itself
	// last byte: end of the message
	msg_size := len(bytes) + 2
	msg := make([]byte, msg_size)

	msg[0] = kind // first byte indicates message type: ERROR, OK, WARN, etc.

	msg[msg_size-1] = END_OF_MESSAGE

	copy(msg[1:msg_size-1], bytes)

	return msg
}

func DecodeResponse(resp string) (byte, string) {
	return resp[0], resp[1 : len(resp)-1]
}
