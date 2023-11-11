#include <string>
#include <HsFFI.h>
#include "Nixfmt_stub.h"

void hs_rts_init(void)
{
  int argc = 0;
  char *argv[] = { (char*)"nixfmt-flib", 0 };
  char **pargv = argv;
  hs_init(&argc, &pargv);
}

const wchar_t* nix_format(std::wstring a1) {
  return static_cast<const wchar_t*>(fformat(a1.data()));
}

void hs_rts_exit(void)
{
  hs_exit();
}
