function softAssert(cond, msg)
    %SOFTASSERT Assert a condition without throwing an error
    %   SOFTASSERT(COND, MSG) displays a warning message, MSG, if COND is false.

    if ~cond
        warning(msg);
    end
end

