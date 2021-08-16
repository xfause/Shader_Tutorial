#ifndef SDF_2D
#define SDF_2D
//transforms

float2 rotate(float2 samplePosition, float rotation){
    const float PI = 3.14159;
    float angle = rotation * PI * 2 * -1;
    float sine, cosine;
    sincos(angle, sine, cosine);
    return float2(cosine * samplePosition.x + sine * samplePosition.y, cosine * samplePosition.y - sine * samplePosition.x);
}

float2 translate(float2 samplePosition, float2 offset){
    //move samplepoint in the opposite direction that we want to move shapes in
    return samplePosition - offset;
}

float2 scale(float2 samplePosition, float scale){
    return samplePosition / scale;
}

//combinations

///basic
float merge(float shape1, float shape2){
    return min(shape1, shape2);
}

float intersect(float shape1, float shape2){
    return max(shape1, shape2);
}

float subtract(float base, float subtraction){
    return intersect(base, -subtraction);
}

float interpolate(float shape1, float shape2, float amount){
    return lerp(shape1, shape2, amount);
}

/// round
float round_merge(float shape1, float shape2, float radius){
    float2 intersectionSpace = float2(shape1 - radius, shape2 - radius);
    intersectionSpace = min(intersectionSpace, 0);
    float insideDistance = -length(intersectionSpace);
    float simpleUnion = merge(shape1, shape2);
    float outsideDistance = max(simpleUnion, radius);
    return  insideDistance + outsideDistance;
}

float round_intersect(float shape1, float shape2, float radius){
    float2 intersectionSpace = float2(shape1 + radius, shape2 + radius);
    intersectionSpace = max(intersectionSpace, 0);
    float outsideDistance = length(intersectionSpace);
    float simpleIntersection = intersect(shape1, shape2);
    float insideDistance = min(simpleIntersection, -radius);
    return outsideDistance + insideDistance;
}

float round_subtract(float base, float subtraction, float radius){
    return round_intersect(base, -subtraction, radius);
}

///champfer
float champfer_merge(float shape1, float shape2, float champferSize){
    const float SQRT_05 = 0.70710678118;
    float simpleMerge = merge(shape1, shape2);
    float champfer = (shape1 + shape2) * SQRT_05;
    champfer = champfer - champferSize;
    return merge(simpleMerge, champfer);
}

float champfer_intersect(float shape1, float shape2, float champferSize){
    const float SQRT_05 = 0.70710678118;
    float simpleIntersect = intersect(shape1, shape2);
    float champfer = (shape1 + shape2) * SQRT_05;
    champfer = champfer + champferSize;
    return intersect(simpleIntersect, champfer);
}

float champfer_subtract(float base, float subtraction, float champferSize){
    return champfer_intersect(base, -subtraction, champferSize);
}

/// round border intersection
float round_border(float shape1, float shape2, float radius){
    float2 position = float2(shape1, shape2);
    float distanceFromBorderIntersection = length(position);
    return distanceFromBorderIntersection - radius;
}

float groove_border(float base, float groove, float width, float depth){
    float circleBorder = abs(groove) - width;
    float grooveShape = subtract(circleBorder, base + depth);
    return subtract(base, grooveShape);
}

//shapes

float circle(float2 samplePosition, float radius){
    //get distance from center and grow it according to radius
    return length(samplePosition) - radius;
}

float rectangle(float2 samplePosition, float2 halfSize){
    float2 componentWiseEdgeDistance = abs(samplePosition) - halfSize;
    float outsideDistance = length(max(componentWiseEdgeDistance, 0));
    float insideDistance = min(max(componentWiseEdgeDistance.x, componentWiseEdgeDistance.y), 0);
    return outsideDistance + insideDistance;
}

// space manipulation
void mirror(inout float2 position){
    position.x = abs(position.x);
}

float2 cells(inout float2 position, float2 period){
    position = fmod(position, period);
    position += period;
    position = fmod(position, period);

    float2 cellIndex = position / period;
    cellIndex = floor(cellIndex);
    return cellIndex;
}

void wobble(inout float2 position, float2 frequency, float2 amount){
    float2 wobble = sin(position.yx * frequency) * amount;
    position = position + wobble;
}

#endif