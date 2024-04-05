import numpy as np
import scipy.stats as stats

def quadratic(bitwidth):
    # Number of quantiles
    n = 2**(bitwidth - 1)

    # Evenly spaced values in the range [0, 1] (excluding endpoints)
    values = np.linspace(0, 1 - 1/(n+1), n)

    # Simplest form to introduce non-linearity
    q_tilde_values = values * (1 + values)

    # Normalize
    q_positive = q_tilde_values / np.max(np.abs(q_tilde_values))

    # Create negative values using the "sign bit" concept
    q_negative = -q_positive

    # Combine positive and negative values
    q = np.concatenate([q_positive, q_negative])

    q = sorted(list(set(list(q))))

    return q

def normal_float(bitwidth):
    # NF4 values taken directly from the paper
    # Follow the AF4 description of the NF4 construction
    first = 2 ** (bitwidth + 1)
    second = 2 ** (bitwidth + 1) - 2
    delta = (1/2) * ((1/first) + (1/second))
    n = 2**(bitwidth-1)
    p = np.linspace(delta, 0.5, n)
    r = np.linspace(0.5, 1-delta, n+1)
    p_values = stats.norm.ppf(p)
    r_values = stats.norm.ppf(r)
    values = np.concatenate([p_values, r_values])
    values = values / np.max(np.abs(values))
    values = sorted(list(set(list(values))))

    return values

def student_float(bitwidth, df=5, normalized=True, prune_ratio=0.0):
    """
    Generates quantization values for the Student's t-distribution with df degrees of freedom.
    """
    assert prune_ratio >= 0.0 and prune_ratio <= 1.0

    first = 2 ** (bitwidth + 1)
    second = 2 ** (bitwidth + 1) - 2
    delta = (1/2) * ((1/first) + (1/second))
    # Assuming pruning the smallest magnitude values
    prune_delta = prune_ratio / 2
    n = 2**(bitwidth-1)
    values = np.array([])
    if prune_ratio > 0.0:
        values = np.concatenate([values, np.array([0])])
        n = n - 1
    p = np.linspace(delta, 0.5 - prune_delta, n)
    r = np.linspace(0.5 + prune_delta, 1-delta, n+1)
    p_values = stats.t.ppf(p, df)
    r_values = stats.t.ppf(r, df)
    values = np.concatenate([p_values, r_values, values])
    if normalized:
        values = values / np.max(np.abs(values))
    values = sorted(list(set(list(values))))

    return values

def integer(bitwidth, asym=True):
    # The total number of quantization levels
    levels = 2 ** (bitwidth - 1) - 1

    # Step between each level
    step = 1.0 / levels

    # Create the positive values
    pos_values = np.arange(step, 1 + step, step)

    # Generate the negative values
    neg_values = -pos_values
    if asym:
       neg_values = np.concatenate((np.array([-(1 + step)]), neg_values))
    
    # Combine the values to return
    total_values = np.concatenate((neg_values, [0], pos_values))
    
    # Normalize all values to handle asym case
    total_values /= np.max(np.abs(total_values))

    # Sort and turn into a list
    total_values = sorted(list(total_values))

    return total_values

def floating_point(E, M, scale=1.0, sub_normal=True, sub_normal_shift=True, extra_point=None):
    bias = (2 ** (E - 1)) - 1
    values = []

    for sign in [0, 1]:
        for exponent in range(2 ** E):
            for mantissa in range(2 ** M):
                if exponent == 0 and mantissa == 0:
                    # Handle "supernormal" logic
                    if sign == 1 and extra_point is not None:
                        value = extra_point
                    else: 
                        value = 0 
                elif exponent == 0 and sub_normal:
                    # Handle subnormal numbers where exponent is 0 but mantissa is not
                    frac_mantissa = mantissa / (2 ** (scale * M))
                    # (1 - bias) deliberate to effectively extend the values of the smallest normalized range
                    sub_normal_shift = 1 if sub_normal_shift else 0
                    value = (-1) ** sign * 2 ** (scale * (sub_normal_shift - bias)) * frac_mantissa
                else:
                    frac_mantissa = mantissa / (2 ** (scale * M))
                    value = (-1) ** sign * 2 ** (scale * (exponent - bias)) * (1 + frac_mantissa)
                values.append(value)
    max_val = np.max(np.abs(values))
    normalized_values = values / max_val
    normalized_values = sorted(list(set(list(normalized_values))))

    return normalized_values


def apot(bitwidth, superprec=False):
    # TODO: handle the general bitwidth case
    assert bitwidth == 4
    values = np.array([-0.625, -0.5, -0.375, -0.25, -0.1875, -0.125, -0.0625,
              0.0, 0.0625, 0.125, 0.1875, 0.25, 0.375, 0.5, 0.625])
    if superprec:
        values = np.concatenate([values, [.3125]])
    max_val = np.max(np.abs(values))
    normalized_values = values / max_val

    return normalized_values


def mokey(bitwidth):
    # TODO: handle the general bitwidth case
    assert bitwidth == 4
    values = np.array([0.010504081765419053, 0.09225323985281077, 0.1886354972378456,
                       0.30227017869480166, 0.4362454681325528, 0.5942023343796616,
                       0.7804334796850028, 1.0])
    values = np.concatenate([-values[::-1], values])
    
    max_val = np.max(np.abs(values))
    normalized_values = values / max_val

    return normalized_values

def generalized_floating_point(E, M, base=2, sub_normal=True):
    bias = (base ** (E - 1)) - 1
    values = []

    for sign in [0, 1]:
        for exponent in range(base ** E):
            for mantissa in range(base ** M):
                if exponent == 0 and mantissa == 0:
                    value = 0
                elif exponent == 0 and sub_normal:
                    # Handle subnormal numbers where exponent is 0 but mantissa is not
                    frac_mantissa = mantissa / (base **  M)
                    # (1 - bias) deliberate to effectively extend the values of the smallest normalized range
                    value = (-1) ** sign * base ** (1 - bias) * frac_mantissa
                else:
                    frac_mantissa = mantissa / (base ** M)
                    value = (-1) ** sign * base ** (exponent - bias) * (1 + frac_mantissa)
                values.append(value)

    max_val = np.max(np.abs(values))
    normalized_values = values / max_val
    normalized_values = sorted(list(set(list(normalized_values))))

    return normalized_values
