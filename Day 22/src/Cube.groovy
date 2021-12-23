class Cube {
    private final Vector3 from
    private final Vector3 to
    private final int sign

    Cube(Vector3 from, Vector3 to, int sign) {
        this.sign = sign
        this.to = to
        this.from = from
    }

    boolean intersectsWith(Cube other) {
        final intersectsX = this.from.x <= other.to.x && this.to.x >= other.from.x
        final intersectsY = this.from.y <= other.to.y && this.to.y >= other.from.y
        final intersectsZ = this.from.z <= other.to.z && this.to.z >= other.from.z
        return intersectsX && intersectsY && intersectsZ
    }

    Cube getProduct(Cube other) {
        final sign = this.sign * other.sign
        
        final Vector3 from = new Vector3(
                Math.max(this.from.x, other.from.x),
                Math.max(this.from.y, other.from.y),
                Math.max(this.from.z, other.from.z)
        )

        final Vector3 to = new Vector3(
                Math.min(this.to.x, other.to.x),
                Math.min(this.to.y, other.to.y),
                Math.min(this.to.z, other.to.z)
        )

        return new Cube(from, to, sign)
    }

    Cube signInverse() {
        return new Cube(from, to, -1 * sign)
    }

    private BigInteger getVolume() {
        final spanX = (BigInteger) (this.to.x - this.from.x + 1l)
        final spanY = (BigInteger) (this.to.y - this.from.y + 1l)
        final spanZ = (BigInteger) (this.to.z - this.from.z + 1l)
        return spanX * spanY * spanZ
    }

    BigInteger getEnabledLits() {
        ((BigInteger) sign) * getVolume()
    }
}
