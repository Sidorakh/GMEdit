a_number = 1;
a_number = undefined; ///want_warn "Can't cast undefined to number"
a_string = "hi!";
a_string = undefined; ///want_warn "Can't cast undefined to string"
a_bool = true;
a_bool = ""; ///want_warn "Can't cast string to bool"
an_array = [];
an_array = 0; ///want_warn "Can't cast number to array"
a_point = new CastPoint();
a_point = 0; ///want_warn "Can't cast number to CastPoint"
