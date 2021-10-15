package qa_common

/* server and a client communication rules */

const (
	ERROR byte = 128 + iota // general error ocured during any operation
	OK
	WARN
	CONN_CLOSED
	STDOUT      // std output of the cmd execution
	STDERR      // std err of the cmd execution
	END_OF_LINE // flag indicating end of the line
	EOF         // end of entire message
	END_OF_MESSAGE
)

func NewResponse(bytes []byte, kind byte) []byte {
	// first byte: type of message - ERROR, OK, WARN, etc
	// msg[first:last-1] = message itself
	// last byte: end of the line
	msg_size := len(bytes) + 2
	msg := make([]byte, msg_size)

	msg[0] = kind // first byte indicates message type: ERROR, OK, WARN, etc.

	msg[msg_size-1] = END_OF_MESSAGE

	copy(msg[1:msg_size-1], bytes)

	return msg
}

func DecodeResponse(resp []byte) (byte, string) {
	if len(resp) > 2 {
		return resp[0], string(resp[1 : len(resp)-1])
	}
	return resp[0], ""
}
