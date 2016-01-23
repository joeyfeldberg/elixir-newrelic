#ifndef MAIN_H
#define MAIN_H
#include <elixir_comm.h>

#include <string>
#include <iostream>
#include <fstream>
#include <vector>

#include "newrelic_collector_client.h"
#include "newrelic_common.h"
#include "newrelic_transaction.h"
#include "operation_msg.pb.h"

void newrelic_status_update(int status);

std::string get_sql_operation(operation_msg::Operation_SegmentDatastoreOperation op);
std::string prase_error(int error_code);

#endif
