
import * as THREE from 'three';


export class CelestialBody extends THREE.Mesh {



    constructor(mass, radius, position, initialVelocity, universe, color, mesh, name = "") {
        if (mesh == null) {
            console.log("no mesh so its earth")
            super(
                new THREE.SphereGeometry(radius, 32, 16),
                new THREE.MeshBasicMaterial({ color: color })
            );
        } else {
            super(mesh.geometry, mesh.material);
        }


        this.mass = mass;
        this.radius = radius;
        this.initialVelocity = initialVelocity;

        this.currentVelocity = initialVelocity;

        console.log("Initial and current V ", this.currentVelocity);
        this.position.copy(position);
        console.log("Initial position: ", this.position)
        this.universe = universe;
        this.name = name;
    }


    init = () => {
        this.currentVelocity = this.initialVelocity;
    }

    updateVelocity = (bodies, timeStep) => {
        const G = this.universe.gravitationalConstant;

        bodies.forEach(other => {
            if (other !== this) {
                // 1. Calculate distance between bodies
                console.log("Body Name: ", this.name);
                console.log("Initial Velocity: ", this.currentVelocity)

                console.log("Other pos", other.position);
                console.log("This pos", this.position);
                const direction = other.position.sub(this.position);
                console.log("Direction: ", direction)

                // 2. Compute squared distance
                const sqrRadius = direction.lengthSq();

                console.log("Sqr Radius: ", sqrRadius)

                // 3. Calculate m1 * m2
                const m1m2 = this.mass * other.mass;

                console.log("M1M2: ", m1m2)

                // 4. Compute direction of the force
                const forceDir = direction.normalize();

                console.log("Force Dir: ", forceDir);

                // 5. Calculate magnitude of the gravitational force
                const forceMagnitude = (G * m1m2) / sqrRadius;

                console.log("Force Mag: ", forceMagnitude)

                // 6. Apply direction to get force vector
                const force = forceDir.multiplyScalar(forceMagnitude);

                console.log("Force final with dir: ", force)


                // Calculate acceleration using F = ma, so a = F / m
                const acceleration = force.divideScalar(this.mass);


                console.log("Acceleration with mass", acceleration);


                // Update current velocity based on acceleration and timeStep
                this.currentVelocity.add(acceleration.multiplyScalar(timeStep));

                console.log("Current velocity: ", this.currentVelocity);
            }
        });
    }


    updatePosition = (timeStep) => {
        console.log("Update pos velocity: ", this.currentVelocity);
        console.log("Current pos before update: ", this.position, "timestep", timeStep);
        this.position.add(this.currentVelocity.multiplyScalar(timeStep));
        console.log("Current pos after update: ", this.position);
    }


}