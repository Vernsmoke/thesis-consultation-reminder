<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        if (! app()->environment(['local', 'testing'])) {
            throw new \RuntimeException('Controlled fixtures only.');
        }
        $password = config('app.demo_password');
        if (! $password) {
            throw new \RuntimeException('Set DEMO_PASSWORD in private environment before seeding.');
        }
        foreach (['student', 'adviser', 'panel', 'coordinator', 'otherstudent'] as $i => $role) {
            DB::table('users')->updateOrInsert(['email' => $role.'@example.test'], ['name' => ['Alex Researcher', 'Casey Adviser', 'Jordan Panel', 'Taylor Coordinator', 'Sam Researcher'][$i],
                'role' => $role === 'otherstudent' ? 'student' : $role, 'password' => Hash::make($password), 'created_at' => now(), 'updated_at' => now()]);
        }
    }
}
