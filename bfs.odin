package bfs

import "core:fmt"
import "core:testing"

import queue "core:container/queue"
import math "core:math/linalg"


bfs_path :: proc(start, goal: math.Vector2f32, grid: [][]int) -> Maybe([dynamic]math.Vector2f32) {
    directions := [?]math.Vector2f32 {
        {-1,0},{1,0},{0,-1},{0,1}
    }

    q: queue.Queue(math.Vector2f32)
    queue.init(&q)
    defer queue.destroy(&q)

    queue.push(&q, start)

    visited := map[math.Vector2f32]bool {}
    defer delete(visited)

    visited[start] = true

    parent := map[math.Vector2f32]math.Vector2f32 {}
    defer delete(parent)
    found := false 

    for queue.len(q) > 0 {
        current := queue.pop_front(&q)

        if current == goal {
            found = true
            break
        }

        for dir, _ in directions {
            neighbour :math.Vector2f32 = {current.x + dir.x, current.y + dir.y}
            
            if int(neighbour.x) >= 0 && int(neighbour.x) < len(grid) && int(neighbour.y) >= 0 && int(neighbour.y) < len(grid[0]) {
                if grid[int(neighbour.x)][int(neighbour.y)] == 0 && !visited[neighbour] {
                    visited[neighbour] = true
                    parent[neighbour] = current
                    queue.push(&q, neighbour)
                }
            }
        }
    }

    if found {
        path := [dynamic]math.Vector2f32{}
        defer delete(path)

        current := goal

        for current != start {
            append(&path, current)
            current = parent[current]
        }
        append(&path, start)

        for i, j := 0, len(path)-1; i < j; i, j = i+1, j-1 {
            path[i], path[j] = path[j], path[i]
        }

        return path
    } else {
        return nil
    }
}

@(test)
foo :: proc(t: ^testing.T) {
    start : math.Vector2f32 = {0, 0}
    end : math.Vector2f32 = {2, 0}

    grid :[][]int = {
        {0,0,0,0,0,0},
        {1,1,1,1,1,0},
        {0,0,0,0,0,0}
    }

    result, ok := bfs_path(start, end, grid).?
    testing.expect(t, ok == true, "failed to find path")
}

@(test)
bar :: proc(t: ^testing.T) {
    start : math.Vector2f32 = {0, 0}
    end : math.Vector2f32 = {2, 0}

    grid :[][]int = {
        {0,0,0,0,1,0},
        {1,1,1,1,1,0},
        {0,0,0,0,0,0}
    }

    result, ok := bfs_path(start, end, grid).?
    testing.expect(t, ok == false, "found unexpected path")
}
