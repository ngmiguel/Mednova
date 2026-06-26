package com.mednova.auth.application.port.out;

import java.time.Duration;

public interface TokenBlacklistPort {

    void blacklist(String jti, Duration ttl);

    boolean isBlacklisted(String jti);
}
