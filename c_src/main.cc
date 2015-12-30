#include "main.h"

#include <iostream>
#include <fstream>

#include <string>
#include <vector>

#include "newrelic_collector_client.h"
#include "newrelic_common.h"
#include "newrelic_transaction.h"
#include "operation_msg.pb.h"

int main(void)
{
  int bytes_read;
  byte buffer[MAX_BUFFER_SIZE];

  newrelic_register_message_handler(newrelic_message_handler);

  while((bytes_read = read_msg(buffer)) > 0)
  {
    operation_msg::Operation msg;
    operation_msg::Response res;
    msg.ParseFromArray(buffer, bytes_read);

    switch (msg.type()) {
      case operation_msg::Operation::INIT: {
        operation_msg::Operation_Init init = msg.init();
        int code = newrelic_init(init.license().c_str(),
                      init.app_name().c_str(),
                      init.language().c_str(),
                      init.language_version().c_str());

        res.set_error(false);
        res.set_code(code);
        break;
      }
      case operation_msg::Operation::TRANSACTION_BEGIN: {
        operation_msg::Operation_TransactionBegin begin = msg.transaction_begin();
        long id = newrelic_transaction_begin();
        int code = newrelic_transaction_set_name(id, begin.name().c_str());
        res.set_error(false);
        res.set_code(code);
        res.set_transaction_id(id);
        break;
      }
      case operation_msg::Operation::TRANSACTION_END: {
        operation_msg::Operation_TransactionEnd end = msg.transaction_end();
        int code = newrelic_transaction_end(end.transaction_id());
        res.set_error(false);
        res.set_code(code);
        break;
      }
      case operation_msg::Operation::TRANSACTION_NOTICE_ERROR: {
        operation_msg::Operation_NoticeError notice = msg.notice_error();
        int code = newrelic_transaction_notice_error(notice.transaction_id(),
                                          notice.exception_type().c_str(),
                                          notice.error_message().c_str(),
                                          notice.stack_trace().c_str(),
                                          notice.stack_frame_delimiter().c_str());

        res.set_transaction_id(notice.transaction_id());
        res.set_code(code);
        res.set_error(false);
        break;
      }
      default:
        res.set_error(true);
        break;
    }

    // I don't like this, maybe it should write directly on the stream?
    int target_size = res.ByteSize();
    byte res_buffer[target_size];
    res.SerializeToArray(res_buffer, target_size);
    send_msg(res_buffer, target_size);
  }

  return 0;
}
