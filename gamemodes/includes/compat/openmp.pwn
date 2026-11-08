// Import after third-party libraries and before local implementations/callers.
// Keep NGG policies distinct from same-named open.mp/YSI APIs.
#define IsNumeric NGRP_IsNumeric

// The local implementation also updates PlayerInfo[pGuns] and restores the loadout.
#define RemovePlayerWeapon NGRP_RemovePlayerWeapon
#define GetWeaponSlot NGRP_GetWeaponSlot
#define IsVehicleOccupied NGRP_IsVehicleOccupied

// NGG's existing two-argument helper has a max-exclusive range. Keep its body and
// callers instead of expanding its declaration through YSI's Random macro.
#if defined Random
    #undef Random
#endif
