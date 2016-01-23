#include "main.h"

using namespace operation_msg;

int main(void)
{
  int bytes_read;
  byte buffer[MAX_BUFFER_SIZE];

  newrelic_register_message_handler(newrelic_message_handler);

  while((bytes_read = read_msg(buffer)) > 0)
  {
    Operation msg;
    Response res;
    int ret_code = 0;
    msg.ParseFromArray(buffer, bytes_read);

    res.set_error(false);
    switch (msg.type()) {
      case Operation::INIT: {
        Operation_Init op = msg.init();
        ret_code = newrelic_init(op.license().c_str(),
                      op.app_name().c_str(),
                      op.language().c_str(),
                      op.language_version().c_str());
        break;
      }
      case Operation::ENABLE_INSTRUMENTATION: {
        Operation_EnableInstrumentation op = msg.enable_instrumentation();
        newrelic_enable_instrumentation(op.set_enabled());
        ret_code = 0;
        break;
      }
      case Operation::RECORD_METRIC: {
        Operation_RecordMetric op = msg.record_metric();
        ret_code = newrelic_record_metric(op.name().c_str(), op.value());
        break;
      }
      case Operation::RECORD_CPU_USAGE: {
        Operation_RecondCPUUsage op = msg.record_cpu_usage();
        ret_code = newrelic_record_cpu_usage(op.cpu_user_time_seconds(),
                                             op.cpu_usage_percent());
        break;
      }
      case Operation::RECORD_MEMORY_USAGE: {
        Operation_RecondMemoryUsage op = msg.record_memory_usage();
        ret_code = newrelic_record_memory_usage(op.memory_megabytes());
        break;
      }
      case Operation::TRANSACTION_BEGIN: {
        Operation_TransactionBegin op = msg.transaction_begin();
        long id = newrelic_transaction_begin();
        if (id < 0) {
          ret_code = id;
          break;
        }

        res.set_transaction_id(id);
        ret_code = newrelic_transaction_set_name(id, op.name().c_str());
        if (ret_code < 0) {
          break;
        }

        if (op.has_set_type_web()) {
          ret_code = newrelic_transaction_set_type_web(id);
          if (ret_code < 0) {
            break;
          }
        }

        if (op.has_category()) {
          ret_code = newrelic_transaction_set_category(id, op.category().c_str());
          if (ret_code < 0) {
            break;
          }
        }

        if (op.has_request_url()) {
          ret_code = newrelic_transaction_set_request_url(id, op.request_url().c_str());
          if (ret_code < 0) {
            break;
          }
        }

        if (op.has_max_trace_segments()) {
          ret_code = newrelic_transaction_set_max_trace_segments(id, op.max_trace_segments());
          if (ret_code < 0) {
            break;
          }
        }

        break;
      }
      case Operation::TRANSACTION_END: {
        Operation_TransactionEnd op = msg.transaction_end();
        ret_code = newrelic_transaction_end(op.transaction_id());
        break;
      }
      case Operation::TRANSACTION_NOTICE_ERROR: {
        Operation_TransactionNoticeError op = msg.transaction_notice_error();
        ret_code = newrelic_transaction_notice_error(op.transaction_id(),
                                          op.exception_type().c_str(),
                                          op.error_message().c_str(),
                                          op.stack_trace().c_str(),
                                          op.stack_frame_delimiter().c_str());
        break;
      }
      case Operation::TRANSACTION_ADD_ATTRIBUTE: {
        Operation_TransactionAddAttribute op = msg.transaction_add_attribute();;
        ret_code = newrelic_transaction_add_attribute(op.transaction_id(),
                                          op.name().c_str(),
                                          op.value().c_str());
        break;
      }
      case Operation::SEGMENT_GENERIC_BEGIN: {
        Operation_SegmentGenericBegin op = msg.segment_generic_begin();
        long id = newrelic_segment_generic_begin(op.transaction_id(),
                                          op.parent_segment_id(),
                                          op.name().c_str());
        if (id < 0) {
          ret_code = id;
        }

        res.set_segment_id(id);
        break;
      }
      case Operation::SEGMENT_DATASTORE_BEGIN: {
        Operation_SegmentDatastoreBegin op = msg.segment_datastore_begin();
        long id = newrelic_segment_datastore_begin(op.transaction_id(),
                                          op.parent_segment_id(),
                                          op.table().c_str(),
                                          get_sql_operation(op.operation()).c_str(),
                                          op.sql().c_str(),
                                          NULL,
                                          NULL);
        if (id < 0) {
          ret_code = id;
        }

        res.set_segment_id(id);
        break;
      }
      case Operation::SEGMENT_EXTERNAL_BEGIN: {
        Operation_SegmentExternalBegin op = msg.segment_external_begin();
        long id = newrelic_segment_external_begin(op.transaction_id(),
                                          op.parent_segment_id(),
                                          op.host().c_str(),
                                          op.name().c_str());
        if (id < 0) {
          ret_code = id;
        }

        res.set_segment_id(id);
        break;
      }
      case Operation::SEGMENT_END: {
        Operation_SegmentEnd op = msg.segment_end();
        ret_code = newrelic_segment_end(op.transaction_id(), op.segment_id());
        break;
      }
      default:
        ret_code = -1;
        res.set_error(true);
        break;
    }

    // I don't like this, maybe it should write directly on the stream?
    res.set_error((ret_code < 0));
    res.set_code(ret_code);
    res.set_error_msg(prase_error(ret_code).c_str());
    int target_size = res.ByteSize();
    byte res_buffer[target_size];
    res.SerializeToArray(res_buffer, target_size);
    send_msg(res_buffer, target_size);
  }

  return 0;
}

std::string get_sql_operation(Operation_SegmentDatastoreOperation op) {
    switch (op) {
      case Operation_SegmentDatastoreOperation_SELECT: {
        return NEWRELIC_DATASTORE_SELECT;
      }
      case Operation_SegmentDatastoreOperation_INSERT: {
        return NEWRELIC_DATASTORE_INSERT;
      }
      case Operation_SegmentDatastoreOperation_UPDATE: {
        return NEWRELIC_DATASTORE_UPDATE;
      }
      case Operation_SegmentDatastoreOperation_DELETE: {
        return NEWRELIC_DATASTORE_DELETE;
      }
    }
}

std::string prase_error(int error_code) {
  switch (error_code) {
    case NEWRELIC_RETURN_CODE_OK: return "OK";
    case NEWRELIC_RETURN_CODE_OTHER: return "OTHER";
    case NEWRELIC_RETURN_CODE_DISABLED: return "DISABLED";
    case NEWRELIC_RETURN_CODE_INVALID_PARAM: return "INVALID_PARAM";
    case NEWRELIC_RETURN_CODE_INVALID_ID: return "INVALID_ID";
    case NEWRELIC_RETURN_CODE_TRANSACTION_NOT_STARTED: return "TRANSACTION_NOT_STARTED";
    case NEWRELIC_RETURN_CODE_TRANSACTION_IN_PROGRESS: return "TRANSACTION_IN_PROGRESS";
    case NEWRELIC_RETURN_CODE_TRANSACTION_NOT_NAMED: return "TRANSACTION_NOT_NAMED";
    default: return "UNKNOWN";
  }
}
