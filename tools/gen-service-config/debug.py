# Global flag to control printing
ENABLE_TRACE = False

def trace(*args, **kwargs):
    if ENABLE_TRACE:
        print(*args, **kwargs)