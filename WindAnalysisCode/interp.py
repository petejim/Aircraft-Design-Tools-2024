from great_circle_calculator import great_circle_calculator as gcc
import math

def calculate_unit_vector(start_point, end_point):
    # Convert latitude and longitude differences to radians
    # Adjust longitude difference for wrap-around
    diff_longitude = end_point[0] - start_point[0]
    diff_longitude = (diff_longitude + 180) % 360 - 180
    diff_longitude = math.radians(diff_longitude)

    diff_latitude = math.radians(end_point[1] - start_point[1])

    # Calculate unit vector components
    # x component (East-West direction)
    x_component = diff_longitude * math.cos(math.radians((start_point[1] + end_point[1]) / 2))

    # y component (North-South direction)
    y_component = diff_latitude

    # Normalize the vector
    magnitude = math.sqrt(x_component**2 + y_component**2)
    if magnitude != 0:
        return x_component / magnitude, y_component / magnitude
    else:
        return 0, 0


def calculate_intermediate_points(waypoints, point_dist):
    # Convert distance per point to kilometers
    distance_per_point = point_dist

    all_intermediate_points = []
    previous_point = None  # Initialize previous point

    for i in range(len(waypoints)):
        start_point = waypoints[i]
        end_point = waypoints[(i + 1) % len(waypoints)]

        # Calculate the total distance between the two waypoints
        total_distance = gcc.distance_between_points(start_point, end_point, unit='miles', haversine=True)

        # Calculate the number of intermediate points needed
        num_points = int(total_distance / distance_per_point)

        if num_points == 0:
            num_points = 1

        # Generate the intermediate points
        segment_points = []

        if i == (len(waypoints) - 1):
            final_point = 1
        else:
            final_point = 0

        for j in range(0, num_points + final_point):
            fraction = j / num_points
            current_point = gcc.intermediate_point(start_point, end_point, fraction)

            # Calculate distance from the previous point
            if previous_point is not None:
                distance_from_previous = gcc.distance_between_points(previous_point, current_point, unit='miles', haversine=True)
                unit_vector = calculate_unit_vector(previous_point, current_point)
            else:
                distance_from_previous = 0.0  # First point has no previous point
                unit_vector = (0.0, 0.0)

            # Append the point with the distance and unit vector components
            segment_points.append((current_point[0], current_point[1], distance_from_previous, unit_vector[0], unit_vector[1]))

            # Update previous point
            previous_point = current_point

        all_intermediate_points.extend(segment_points)

    return all_intermediate_points


points = calculate_intermediate_points(waypoints, point_dist)

for point in points:
    print(point)
