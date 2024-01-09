

const lerp = (A, B, t) => {
    return (B - A) + A * t
}

const distance = (x1, y1, x2, y2) => {
    const dx = x2 - x1
    const dy = y2 - y1
    return Math.sqrt(dx * dx + dy * dy)
}